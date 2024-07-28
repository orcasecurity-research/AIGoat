import React from 'react';
// import Link from 'next/link';
import {Product, ProductComment} from '../../actions';
// import { Routes, Route } from 'react-router-dom';
import { Row, Col, Card, Typography, Button } from 'antd';
import { Comment } from 'antd';

import { SkeletonListContext } from '../../contexts';


interface CommentsProps {
  comment: ProductComment;
}

const GeneralComment: React.FC<CommentsProps> = ({ comment }) => {

  return (
      <Comment
          actions={comment.actions}
          author={comment.author}
          avatar={comment.avatar}
          content={comment.content}
          datetime={comment.datetime}
        />
  )
};

export default GeneralComment;
