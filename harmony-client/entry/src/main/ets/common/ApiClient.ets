import { http } from '@kit.NetworkKit';

export interface Shop {
  id: number;
  name: string;
  area?: string;
  address?: string;
  openHours?: string;
  score?: number;
}

export interface Voucher {
  id: number;
  title: string;
  subTitle?: string;
  rules?: string;
  payValue?: number;
  actualValue?: number;
  stock?: number;
}

interface ApiResult<T> {
  success: boolean;
  errorMsg?: string;
  data?: T;
}

// 修改为 Previewer 或设备可访问的服务地址。不要在此保存真实凭据。
export const MOCK_URL: string = 'http://127.0.0.1:18081';
export const BACKEND_URL: string = 'http://127.0.0.1:8081';

export class ApiClient {
  private baseUrl: string;
  private token: string;

  constructor(baseUrl: string, token: string = '') {
    this.baseUrl = baseUrl;
    this.token = token;
  }

  private async get<T>(path: string): Promise<T> {
    const request = http.createHttp();
    try {
      const headers: Record<string, string> = { 'Accept': 'application/json' };
      if (this.token.length > 0) { headers['authorization'] = this.token; }
      const response = await request.request(this.baseUrl + path, {
        method: http.RequestMethod.GET, header: headers, connectTimeout: 6000, readTimeout: 6000,
        expectDataType: http.HttpDataType.STRING
      });
      if (response.responseCode !== 200) { throw new Error('HTTP ' + response.responseCode); }
      const body = JSON.parse(response.result as string) as ApiResult<T>;
      if (!body.success || body.data === undefined || body.data === null) {
        throw new Error(body.errorMsg || '服务未返回有效数据');
      }
      return body.data;
    } finally {
      request.destroy();
    }
  }

  shops(keyword: string): Promise<Shop[]> {
    return this.get<Shop[]>('/shop/of/name?current=1&name=' + encodeURIComponent(keyword));
  }

  shop(id: number): Promise<Shop> { return this.get<Shop>('/shop/' + id); }
  vouchers(id: number): Promise<Voucher[]> { return this.get<Voucher[]>('/voucher/list/' + id); }
}
