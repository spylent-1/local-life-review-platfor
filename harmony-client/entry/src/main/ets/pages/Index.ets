import { ApiClient, Shop, Voucher, MOCK_URL, BACKEND_URL } from '../common/ApiClient';

class DetailParams {
  id: number = 0;
  baseUrl: string = '';
  token: string = '';
  source: string = '';
}

@Component
struct ShopCard {
  shop: Shop = { id: 0, name: '' };
  onSelect: () => void = () => {};

  build() {
    Column({ space: 8 }) {
      Row() {
        Text(this.shop.name).fontSize(19).fontWeight(FontWeight.Bold).layoutWeight(1)
        Text('查看 ›').fontColor('#155EEF').fontSize(14)
      }.width('100%')
      Text(this.shop.area || '暂无商圈信息').fontSize(14).fontColor('#64748B').width('100%')
      Text(this.shop.address || '暂无地址信息').fontSize(14).fontColor('#475467').width('100%').maxLines(2)
    }
    .alignItems(HorizontalAlign.Start).width('100%').padding(18).backgroundColor(Color.White)
    .borderRadius(14).onClick(() => this.onSelect())
  }
}

@Entry
@Component
struct Index {
  private stack: NavPathStack = new NavPathStack();
  @State shops: Shop[] = [];
  @State keyword: string = '';
  @State source: string = '网络 Mock';
  @State baseUrl: string = MOCK_URL;
  @State token: string = '';
  @State loading: boolean = false;
  @State error: string = '';
  private requestVersion: number = 0;

  aboutToAppear(): void { this.load(); }

  async load(): Promise<void> {
    const version = ++this.requestVersion;
    this.loading = true;
    this.error = '';
    try {
      const result = await new ApiClient(this.baseUrl, this.token).shops(this.keyword);
      if (version === this.requestVersion) { this.shops = result; }
    } catch (error) {
      if (version === this.requestVersion) { this.shops = []; this.error = '请求失败，请检查服务地址、网络和服务状态。'; }
    } finally { if (version === this.requestVersion) { this.loading = false; } }
  }

  @Builder
  pages(name: string, param: Object) {
    if (name === 'detail') { DetailPage({ params: param as DetailParams }); }
  }

  build() {
    Navigation(this.stack) {
      Column({ space: 14 }) {
        Column({ space: 8 }) {
          Text('发现可用资源').fontSize(26).fontWeight(FontWeight.Bold).fontColor('#101828').width('100%')
          Text('浏览场所与权益，数据来自 ' + this.source).fontSize(14).fontColor('#667085').width('100%')
        }.width('100%').alignItems(HorizontalAlign.Start)
        Row({ space: 8 }) {
          Button('网络 Mock').type(ButtonType.Capsule).fontSize(13)
            .backgroundColor(this.source === '网络 Mock' ? '#155EEF' : '#98A2B3')
            .onClick(() => { this.source = '网络 Mock'; this.baseUrl = MOCK_URL; this.load(); })
          Button('FlashPass 后端').type(ButtonType.Capsule).fontSize(13)
            .backgroundColor(this.source === 'FlashPass 后端' ? '#155EEF' : '#98A2B3')
            .onClick(() => { this.source = 'FlashPass 后端'; this.baseUrl = BACKEND_URL; this.load(); })
        }.width('100%')
        if (this.source === 'FlashPass 后端') {
          TextInput({ placeholder: '权益接口 Token（可选）', text: this.token })
            .onChange((value: string) => { this.token = value; }).width('100%')
        }
        Row({ space: 8 }) {
          TextInput({ placeholder: '搜索资源名称', text: this.keyword })
            .onChange((value: string) => { this.keyword = value; }).layoutWeight(1)
          Button('搜索').onClick(() => this.load())
        }.width('100%')
        Row() {
          Text('资源列表').fontSize(18).fontWeight(FontWeight.Medium).layoutWeight(1)
          Button('刷新').fontSize(13).onClick(() => this.load())
        }.width('100%')
        if (this.loading) {
          Row({ space: 8 }) { LoadingProgress().width(22).height(22); Text('正在加载数据') }.padding(20)
        } else if (this.error.length > 0) {
          Column({ space: 10 }) { Text(this.error).fontColor('#B42318'); Button('重试').onClick(() => this.load()) }.padding(24)
        } else if (this.shops.length === 0) {
          Text('暂无匹配资源，可更换关键词后重试。').fontColor('#667085').padding(24)
        } else {
          List({ space: 10 }) {
            ForEach(this.shops, (shop: Shop) => {
              ListItem() {
                ShopCard({ shop: shop, onSelect: () => {
                  const params: DetailParams = { id: shop.id, baseUrl: this.baseUrl, token: this.token, source: this.source };
                  this.stack.pushPathByName('detail', params);
                } })
              }
            }, (shop: Shop) => shop.id.toString())
          }.layoutWeight(1).width('100%')
        }
      }.padding(18).width('100%').height('100%').backgroundColor('#F2F4F7')
    }.title('FlashPass').mode(NavigationMode.Stack).navDestination(this.pages)
  }
}

@Component
struct DetailPage {
  params: DetailParams = new DetailParams();
  @State shop: Shop = { id: 0, name: '' };
  @State vouchers: Voucher[] = [];
  @State loading: boolean = false;
  @State shopError: string = '';
  @State voucherError: string = '';

  aboutToAppear(): void { this.load(); }

  async load(): Promise<void> {
    if (this.loading) { return; }
    this.loading = true;
    this.shopError = ''; this.voucherError = '';
    const api = new ApiClient(this.params.baseUrl, this.params.token);
    try { this.shop = await api.shop(this.params.id); }
    catch (error) { this.shopError = '资源详情加载失败，请检查网络或重试。'; }
    try { this.vouchers = await api.vouchers(this.params.id); }
    catch (error) { this.vouchers = []; this.voucherError = '权益加载失败；后端模式需要有效登录 Token。'; }
    this.loading = false;
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 14 }) {
          Text('数据来源：' + this.params.source).fontColor('#667085').fontSize(13).width('100%')
          if (this.loading) { LoadingProgress().width(28).height(28) }
          if (this.shopError.length > 0) { Text(this.shopError).fontColor('#B42318') }
          else if (this.shop.name.length > 0) {
            Column({ space: 10 }) {
              Text(this.shop.name).fontSize(24).fontWeight(FontWeight.Bold).width('100%')
              Text('商圈：' + (this.shop.area || '暂无')).width('100%')
              Text('地址：' + (this.shop.address || '暂无')).width('100%')
              Text('营业时间：' + (this.shop.openHours || '暂无')).width('100%')
            }.padding(18).width('100%').backgroundColor(Color.White).borderRadius(14)
          }
          Row() { Text('可用权益').fontSize(18).fontWeight(FontWeight.Bold).layoutWeight(1); Button('刷新').onClick(() => this.load()) }.width('100%')
          if (this.voucherError.length > 0) { Text(this.voucherError).fontColor('#B42318') }
          else if (!this.loading && this.vouchers.length === 0) { Text('暂无权益').fontColor('#667085') }
          ForEach(this.vouchers, (item: Voucher) => {
            Column({ space: 8 }) {
              Text(item.title).fontSize(17).fontWeight(FontWeight.Medium).width('100%')
              Text(item.subTitle || '查看具体使用规则').fontColor('#667085').width('100%')
              Text(item.rules || '暂无规则说明').fontSize(13).fontColor('#475467').width('100%')
            }.padding(16).width('100%').backgroundColor(Color.White).borderRadius(14)
          }, (item: Voucher) => item.id.toString())
          Text('本页面仅用于查询展示，不提供下单操作。').fontSize(12).fontColor('#667085').width('100%')
        }.padding(18).width('100%').alignItems(HorizontalAlign.Start)
      }.backgroundColor('#F2F4F7').width('100%').height('100%')
    }.title('资源详情')
  }
}
