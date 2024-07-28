import React, { useState, useEffect } from 'react';
import { Row, Col, Badge, Modal, Input, Button, Layout, message } from 'antd';
import Link from 'next/link';
import { ShoppingCartOutlined } from '@ant-design/icons';
import { useCartSelector } from '../../../selectors';
import { orcaApi } from '../../../config';
import './MainNav.less';
import {fetchCartProducts} from "../../../actions";

const { Header } = Layout;

const MainNav = () => {
  const { totalItems } = useCartSelector();
  const [isModalVisible, setIsModalVisible] = useState(false);
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');

  useEffect(() => {
    const token = localStorage.getItem('authToken');
    const storedUsername = localStorage.getItem('username');
    // console.log(token, storedUsername, token && storedUsername)
    if (token && storedUsername) {
      setIsLoggedIn(true);
      setUsername(storedUsername);
    }
  }, []);


  const showModal = () => {
    setIsModalVisible(true);
  };

const handleOk = () => {
  if (username && password) {
    // Call login API
    orcaApi.post('/api/login', { username, password })
      .then(response => {
        // console.log(response.data)
        const { token } = response.data;
        localStorage.setItem('authToken', token);
        localStorage.setItem('username', username)// Store token
        setIsLoggedIn(true);
        setIsModalVisible(false);
      })
      .catch(error => {
        message.error('Login failed');
        console.error('Error logging in:', error);
      });
  }
};

  const handleCancel = () => {
    setIsModalVisible(false);
  };

  const handleLogout = () => {
    localStorage.removeItem('authToken');
    localStorage.removeItem('username');
    setIsLoggedIn(false);
    setUsername('');
    setPassword('');
    message.success('Logged out successfully');
  };

  const buttonStyle = {
    color: 'inherit',
    ':hover': {
      color: '#1890ff',
    },
    ':active': {
      color: 'inherit',
    },
    ':focus': {
      color: 'inherit',
      outline: 'none',
    },
  };

  return (
    <Header className="main-nav">
      <Row justify="space-between">
        <Col span={6}>
          <Row className="left-nav-items" justify="space-between" style={{ width: '100%' }}>
            <Col span={6}>
              <img src="/logo.png" style={{ padding: 6, width: 40, marginRight: 50 }} />
            </Col>
            <Col span={6}>
              <Link href="/">
                <a>Home</a>
              </Link>
            </Col>
            <Col span={12}>
              <Link href="/product-search">
                <a>Product Search</a>
              </Link>
            </Col>
          </Row>
        </Col>
        <Col span={4} style={{ textAlign: 'right' }}>
          <Row className="left-nav-items" justify="space-between" style={{ width: '100%' }}>
            <Col span={14}>
              <Link href="/cart">
                <div>
                  <Badge
                    count={totalItems}
                    style={{
                      backgroundColor: '#fff',
                      color: '#999',
                      boxShadow: '0 0 0 1px #d9d9d9 inset',
                    }}
                  >
                    <ShoppingCartOutlined
                      style={{ fontSize: 25, cursor: 'pointer', verticalAlign: -5.5 }}
                    />
                  </Badge>
                </div>
              </Link>
            </Col>
            <Col span={10}>
              {isLoggedIn ? (
                <Button type="link" style={buttonStyle} onClick={handleLogout}>
                  {username}, Logout
                </Button>
              ) : (
                <Button type="link" style={buttonStyle} onClick={showModal}>
                  Login
                </Button>
              )}
            </Col>
          </Row>
        </Col>
      </Row>

      <Modal
        title="Login"
        visible={isModalVisible}
        onOk={handleOk}
        onCancel={handleCancel}
        okText="Login"
      >
        <Input
          placeholder="Username"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
          style={{ marginBottom: 10 }}
        />
        <Input.Password
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
      </Modal>
    </Header>
  );
};

export default MainNav;
