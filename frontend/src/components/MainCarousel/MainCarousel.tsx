import React from 'react';
import { Carousel } from 'antd';

const contentStyle: React.CSSProperties = {
  height: '250px',
  color: '#fff',
  textAlign: 'center',
  margin: 0,
  overflow: "hidden",
  width: '100%',
  position: 'relative',
};

const imageStyle: React.CSSProperties = {
  width: '100%',
  height: '100%',
  objectFit: 'cover', // Ensures the image covers the container without stretching
};

const MainCarousel = () => {
  return (
      <Carousel autoplay style={{margin: 0, overflow: "hidden", height: "500px"}} className="carousel" speed={4000}>
          <div className="carousel-item" style={contentStyle}>
              <img src="/images/carousel-demo-images/1.jpg" style={imageStyle}/>
          </div>
          <div className="carousel-item" style={contentStyle}>
              <img src="/images/carousel-demo-images/2.jpg" style={imageStyle}/>
          </div>
          <div className="carousel-item" style={contentStyle}>
              <img src="/images/carousel-demo-images/4.jpg" style={imageStyle}/>
          </div>
          <div className="carousel-item" style={contentStyle}>
              <img src="/images/carousel-demo-images/5.jpg" style={imageStyle}/>
          </div>
      </Carousel>
  );
};

export default MainCarousel;
