<%@ page language="java" contentType="text/html; charset=utf-8" pageEncoding="utf-8"%>
<% 
// response.addCookie(new javax.servlet.http.Cookie("SameSite", "None"));
// response.addCookie(new javax.servlet.http.Cookie("Secure", ""));
%>
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" type="text/css" href="http://unpkg.com/view-design/dist/styles/iview.css">
    <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
    <script type="text/javascript" src="http://unpkg.com/view-design/dist/iview.min.js"></script>
  <script src="https://cdn.staticfile.org/axios/0.18.0/axios.min.js"></script>
  
  <style scoped>
  body {
  	margin: 0;
  	padding: 0;
  	border:0;
  }
  body::-webkit-scrollbar {
	  display: none; /* Chrome Safari */
	}
  
.layout {
    background: #f5f7f9;
    position: relative;
    overflow: hidden;
    width:100%;
    height:100%;
}
.layout-logo {
    width: 100px;
    height: 30px;
    background: #5b6270;
    border-radius: 3px;
    float: left;
    position: relative;
    top: 15px;
    left: 20px;
}
.layout-nav {
    width: 420px;
    margin: 0 auto;
    margin-right: 20px;
}
.layout-footer-center {
    text-align: center;
}
.aaa {
	width:100%;
    height:100%;
    height:500px;
    background-color:#cdcdcd;
}
</style>
</head>
<body >
<Row class-name="aaa">
<i-col class-name="aaa">
<div id="app" class="layout">
        <Layout>
            <Header>
                <i-menu mode="horizontal" theme="dark" active-name="1">
                    <div class="layout-logo"></div>
                    <div class="layout-nav">
                        <menu-item name="1">
                            <Icon type="ios-navigate"></Icon>
                            Item 1
                        </menu-item>
                        <menu-item name="2">
                            <Icon type="ios-keypad"></Icon>
                            Item 2
                        </menu-item>
                        <menu-item name="3">
                            <Icon type="ios-analytics"></Icon>
                            Item 3
                        </menu-item>
                        <menu-item name="4">
                            <Icon type="ios-paper"></Icon>
                            Item 4
                        </menu-item>
                    </div>
                </i-menu>
            </Header>
            <Content :style="{padding: '0 50px'}">
                <Card>
                    <div style="min-height: 100px;">
                        Content
                    </div>
                </Card>
            </Content>
            <Footer class="layout-footer-center">2011-2016 &copy; TalkingData</Footer>
        </Layout>
    </div>
  </i-col>  
</Row>    
<script>
    var vm = new Vue({
        el: '#app',
        data: {
            visible: false,
            value: [20, 30],
        },
        methods: {
            show: function () {
                this.visible = true;
            }
        }
    });
  </script>  
</body>
</html>