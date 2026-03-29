package com.vitality.infrastructure.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.vitality.entity.BalanceTransaction;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface BalanceTransactionMapper extends BaseMapper<BalanceTransaction> {
}
