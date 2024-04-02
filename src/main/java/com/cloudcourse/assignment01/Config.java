package com.cloudcourse.assignment01;

import com.cloudcourse.assignment01.model.User;
import com.cloudcourse.assignment01.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.servlet.config.annotation.ContentNegotiationConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

// Configure JSON as the default format for request and response payloads
@Configuration
@EnableWebSecurity
public class Config extends WebSecurityConfigurerAdapter implements WebMvcConfigurer {

    @Bean
    @Qualifier("bcryptPasswordEncoder")
    public BCryptPasswordEncoder bCryptPasswordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http
                .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS) // Set session creation policy to STATELESS
                .and()
                .authorizeRequests()
                .antMatchers(HttpMethod.PUT,"/v1/user/self").authenticated()
                .antMatchers(HttpMethod.GET,"/v1/user/self").authenticated()
                .antMatchers(HttpMethod.POST, "/v1/user").permitAll() // Allow unauthenticated access to this endpoint
                .antMatchers(HttpMethod.GET, "/v1/user/verify").permitAll() // Allow unauthenticated access to this endpoint
                .anyRequest().permitAll()
                .and()
                .httpBasic()
                .and()
                .csrf().disable();
    }

    @Override
    public void configureContentNegotiation(ContentNegotiationConfigurer configurer) {
        configurer.defaultContentType(MediaType.APPLICATION_JSON);
    }

    @Bean
    public UserDetailsService userDetailsService(UserService userService) {
        return new UserDetailsService() {
            @Override
            public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
                User user = userService.getUserByEmail(email);

                if (user == null) {
                    throw new UsernameNotFoundException("User not found with email: " + email);
                }

                return org.springframework.security.core.userdetails.User.builder()
                        .username(user.getEmail())
                        .password(user.getPassword())
                        .roles("USER")
                        .build();
            }
        };
    }

}