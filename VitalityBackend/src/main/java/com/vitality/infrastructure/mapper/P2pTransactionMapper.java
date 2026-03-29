package com.vitality.infrastructure.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.vitality.entity.P2pTransaction;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface P2pTransactionMapper extends BaseMapper<P2pTransaction> {
}
