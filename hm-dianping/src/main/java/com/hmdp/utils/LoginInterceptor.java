package com.hmdp.utils;

import cn.hutool.core.bean.BeanUtil;
import com.hmdp.dto.UserDTO;
import com.hmdp.entity.User;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public class LoginInterceptor implements HandlerInterceptor{

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
       //获取session
        HttpSession session = request.getSession();
        //获取当前用户
        Object user = session.getAttribute("user");
        //判断用户是否存在
        if (user == null) {
            response.setStatus(401);
            return false;
        }
        //存在，保存用户信息
        if (user instanceof UserDTO) {
            UserHolder.saveUser((UserDTO) user);
        } else if (user instanceof User) {
            UserHolder.saveUser(BeanUtil.copyProperties(user, UserDTO.class));
        }
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
       //移除用户
        UserHolder.removeUser();
    }
}
