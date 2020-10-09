--t_gyl3_orgxx表  dd807 --累积的向上表数据 呈现表

select jbxx.集团,  
       count(distinct jbxx.受票方) 分公司数,
       count(distinct jbxx.org_id_new) 项目总数,
       count(distinct case when jbxx.项目是否活跃 = '是' then jbxx.org_id_new end) 活跃项目数,
       count(distinct case when  jbxx.项目是否活跃 = '是' and zuz.opening_time is not null  then jbxx.org_id_new end) 系统升级项目,
       zzsx.最早上线时间,
       count(distinct case when jbxx.供应链金融激活时间 is not null then jbxx.受票方 end) 上线分公司数,
       count(distinct case when jbxx.供应链金融激活时间 is not null then jbxx.org_id_new end) 上线项目数,  
       count(distinct case when jbxx.供应链金融状态 = '活跃' then jbxx.受票方 end) 金融活跃分公司数,
       count(distinct case when jbxx.供应链金融状态 = '活跃' then jbxx.org_id_new end) 金融活跃项目数,
       case  when sum(nvl(d.yqe, 0)) > 0 then  '是' else '否'  end 是否有逾期,             
       sum(nvl(e.ze, 0)) 供应链金融交易额,
       sum(nvl(e.yfe, 0)) 预付金交易额,
       sum(nvl(e.dfe, 0)) 到付金交易额,
       sum(nvl(e.tqe, 0)) 提前收款交易额,
       sum(nvl(e.wxe, 0)) 外协交易额,
       sum(nvl(e.wxt, 0)) 外协提前收款交易额,
       sum(nvl(e.zde, 0)) 在贷额,
       max(d.yq_m) 逾期天数_最大, 
       sum(nvl(d.yqe, 0)) 逾期金额  
from 
    t_gyl3_orgxx jbxx
    left join 
    ods.T_ORGNIZATION zuz on jbxx.企业ID=zuz.org_id
    left join
     (select 集团,min(供应链金融激活时间) 最早上线时间 from t_gyl3_orgxx where 供应链金融激活时间 is not null --获取上线供应链金融的集团及最早上线时间
      and  NOT REGEXP_LIKE (企业名称, '(测试|演示|商信金|路歌|好运宝|管车宝)') and 企业ID !='373845' group by 集团 ) zzsx--排除东岭商信金到付金373845 
         -- z.DRAWEE_CUSTOMER_LEVEL like'A%'   
      on zzsx.集团=jbxx.集团
    left join (select a.org_id,
                    max(case
                          when a.OVERDUE_STATE = 1 and a.REPAYMENT_STATE = 0 then--逾期状态1: 已逾期  还款状态0：未还款
                           ROUND(TO_NUMBER(sysdate - a.EXPIRE_REPAYMENT_DATE)) --到期还款日期
                        end) yq_m, ---逾期天数_最大,
                    sum(case
                          when a.OVERDUE_STATE = 1 and a.REPAYMENT_STATE = 0 then--逾期状态1: 已逾期  还款状态0：未还款
                           nvl(a.FINANCE_ALL_FREIGHT, 0)  --供应链金融总金额
                        end) yqe --逾期金额,
               from ods.T_M_SUPPLY_FINANCE_BILL a
               where a.IS_DEL = 0 and a.org_id not in ('39016','163369','8357454','444889','8376278','8393852','8381021','8380051','8360288','8378340','8360230')--招商集团测试账号
                and a.BILL_TYPE in (0, 1, 2, 3)--账单类型 0：油料（默认值）_预付金 1：司机金融_到付金1 2：到付金2 3：外协金融
              group by a.org_id) d
    on d.org_id = jbxx.企业ID
  left join (select b.org_id,
                    sum(nvl(a.PAY_ACTUAL_MONEY, 0)) ze, ---PAY_ACTUAL_MONEY实际支付金额--供应链金融交易额
                    sum(case
                          when b.PAY_way = 4 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) yfe, --预付金交易额
                    sum(case
                          when b.PAY_way in (5, 6) then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) dfe, --到付金交易额
                    sum(case
                          when b.POS_WITHDRAWAL_WAY = 1 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) tqe, --提前收款交易额
                    sum(case
                          when b.PAY_way = 7 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) wxe, --外协交易额
                    sum(case
                          when b.POS_WITHDRAWAL_WAY = 1 and b.PAY_way = 7 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) wxt, --外协提前收款交易额                     
                    sum(case
                          when (a.ARRIVE_TIME is not null and--到账时间不为空 企业未还款
                               a.REPAYMENT_STATE = 0) then--还款状态0：未还款
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) zde --在贷额
               from ods.T_TAX_POS_INFO_DETAIL a
               left join ods.T_TAX_POS_INFO b
                 on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
              where b.PAY_STATE = 2 and b.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')
                and b.IS_DEL = 0
                and b.PAY_way in (4, 5, 6, 7)
              group by b.org_id) e
    on e.org_id = jbxx.企业ID           
where  zzsx.最早上线时间 is not null
    -- and jbxx.IS_DEL = 0
    --and jbxx.DRAWEE_CUSTOMER_LEVEL like 'A%'
    and  NOT REGEXP_LIKE (jbxx.企业名称, '(测试|演示)')
    and  exists
     (select 1
          from ods.T_TAX_WAYBILL x
         where x.is_del = 0 
           and x.created_time >= to_date('2019-05-01', 'yyyy-mm-dd')
           and x.org_id = jbxx.企业ID)
group by jbxx.集团,zzsx.最早上线时间;



--t_gyl3_orgxx表  dd817 --周维度的向上表数据 呈现表
select jbxx.集团,
       count(distinct jbxx.受票方) 分公司数,
       count(distinct jbxx.org_id_new) 项目总数,
       count(distinct case when jbxx.项目是否活跃 = '是' then jbxx.org_id_new end) 活跃项目数,
       count(distinct case when  jbxx.项目是否活跃 = '是' and zuz.opening_time is not null  then jbxx.org_id_new end) 系统升级项目,
       zzsx.最早上线时间,
       count(distinct case when jbxx.供应链金融激活时间 is not null then jbxx.受票方 end) 上线分公司数,
       count(distinct case when jbxx.供应链金融激活时间 is not null then jbxx.org_id_new end) 上线项目数,  
       count(distinct case when jbxx.供应链金融状态 = '活跃' then jbxx.受票方 end) 金融活跃分公司数,
       count(distinct case when jbxx.供应链金融状态 = '活跃' then jbxx.org_id_new end) 金融活跃项目数,
       case  when sum(nvl(d.yqe, 0)) > 0 then  '是' else '否'  end 是否有逾期, 
       sum(nvl(e1.ze, 0)) 供应链金融交易额, --修改             
       sum(nvl(e.ze, 0)) 供应链金融周交易额,
       sum(nvl(e.yfe, 0)) 预付金周交易额,
       sum(nvl(e.dfe, 0)) 到付金周交易额,
       sum(nvl(e.tqe, 0)) 提前收款周交易额,
       sum(nvl(e.wxe, 0)) 外协周交易额,
       sum(nvl(e.wxt, 0)) 外协提前收款周交易额,
       sum(nvl(e1.zde, 0)) 在贷额,
       max(d.yq_m) 逾期天数_最大, 
       sum(nvl(d.yqe, 0)) 逾期金额  
from 
    t_gyl3_orgxx jbxx
left join ods.T_ORGNIZATION zuz on jbxx.企业ID=zuz.org_id
left join
     (select 集团,min(供应链金融激活时间) 最早上线时间 from t_gyl3_orgxx where 供应链金融激活时间 is not null --获取上线供应链金融的集团及最早上线时间
      and  NOT REGEXP_LIKE (企业名称, '(测试|演示|商信金|路歌|好运宝|管车宝)') and 企业ID !='373845' group by 集团 ) zzsx--排除东岭商信金到付金373845 
         -- z.DRAWEE_CUSTOMER_LEVEL like'A%'   
      on zzsx.集团=jbxx.集团
    left join (select a.org_id,
                    max(case
                          when a.OVERDUE_STATE = 1 and a.REPAYMENT_STATE = 0 then--逾期状态1: 已逾期  还款状态0：未还款
                           ROUND(TO_NUMBER(sysdate - a.EXPIRE_REPAYMENT_DATE)) --到期还款日期
                        end) yq_m, ---逾期天数_最大,
                    sum(case
                          when a.OVERDUE_STATE = 1 and a.REPAYMENT_STATE = 0 then--逾期状态1: 已逾期  还款状态0：未还款
                           nvl(a.FINANCE_ALL_FREIGHT, 0)  --供应链金融总金额
                        end) yqe --逾期金额,
               from ods.T_M_SUPPLY_FINANCE_BILL a
               where a.IS_DEL = 0 and a.org_id not in ('39016','163369','8357454','444889','8376278','8393852','8381021','8380051','8360288','8378340','8360230')--招商集团测试账号
                and a.BILL_TYPE in (0, 1, 2, 3)--账单类型 0：油料（默认值）_预付金 1：司机金融_到付金1 2：到付金2 3：外协金融 
              group by a.org_id) d
    on d.org_id = jbxx.企业ID
  left join (select b.org_id,
                    sum(nvl(a.PAY_ACTUAL_MONEY, 0)) ze, ---PAY_ACTUAL_MONEY实际支付金额--供应链金融交易额
                    sum(case
                          when b.PAY_way = 4 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) yfe, --预付金交易额
                    sum(case
                          when b.PAY_way in (5, 6) then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) dfe, --到付金交易额
                    sum(case
                          when b.POS_WITHDRAWAL_WAY = 1 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) tqe, --提前收款交易额
                    sum(case
                          when b.PAY_way = 7 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) wxe, --外协交易额
                    sum(case
                          when b.POS_WITHDRAWAL_WAY = 1 and b.PAY_way = 7 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) wxt, --外协提前收款交易额                     
                    sum(case
                          when (a.ARRIVE_TIME is not null and--到账时间不为空 企业未还款
                               a.REPAYMENT_STATE = 0) then--还款状态0：未还款
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) zde --在贷额
               from ods.T_TAX_POS_INFO_DETAIL a
               left join ods.T_TAX_POS_INFO b on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
               left join t_y_s u on u.org_id = b.org_id
              where b.PAY_STATE = 2 
                and b.IS_DEL = 0
                and b.PAY_way in (4, 5, 6, 7)
                and b.PAY_TIME > u.CREATED_TIME
                and b.PAY_TIME>=to_date(&statedate,'yyyy-mm-dd') --输入起始时间
                and b.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')  --输入结束时间
              group by b.org_id) e
    on e.org_id = jbxx.企业ID
left join (select b.org_id,
                    sum(nvl(a.PAY_ACTUAL_MONEY, 0)) ze, ---PAY_ACTUAL_MONEY实际支付金额--供应链金融交易额
                    sum(case
                          when (a.ARRIVE_TIME is not null and--到账时间不为空 企业未还款
                               a.REPAYMENT_STATE = 0) then--还款状态0：未还款
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) zde --在贷额                   
               from ods.T_TAX_POS_INFO_DETAIL a
               left join ods.T_TAX_POS_INFO b on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
               left join t_y_s u on u.org_id = b.org_id
              where b.PAY_STATE = 2 
                and b.IS_DEL = 0
                and b.PAY_way in (4, 5, 6, 7)
                and b.PAY_TIME > u.CREATED_TIME
                and b.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')  --输入结束时间
              group by b.org_id) e1 on e1.org_id = jbxx.企业ID        
where  zzsx.最早上线时间 is not null
    -- and jbxx.IS_DEL = 0
    --and jbxx.DRAWEE_CUSTOMER_LEVEL like 'A%'
    and  NOT REGEXP_LIKE (jbxx.企业名称, '(测试|演示)')
    and  exists
     (select 1
          from ods.T_TAX_WAYBILL x
         where x.is_del = 0 
           and x.created_time >= to_date('2019-05-01', 'yyyy-mm-dd')
           and x.org_id = jbxx.企业ID)
group by jbxx.集团,zzsx.最早上线时间;



---select * from  t_gyl3_orgxx12

select sy.*,sx.*
from(select tgo.集团,
count(distinct tgo.org_id_new ) 项目总数,
count(distinct case when tgo.项目是否活跃='是' then tgo.org_id_new end) 活跃项目总数,
count(distinct case when tgo.项目是否活跃='是' then 
               case when tgo.是否实施快路宝='否' then tgo.org_id_new end end) 操作系统未升级项目数,
count(distinct case when tgo.项目是否活跃='是' then 
               case when tgo.是否实施快路宝='是' then tgo.org_id_new end end) 操作系统升级项目数,
count(distinct case when tgo.是否是供应链金融项目='否' then tgo.org_id_new end) 未开通供应链金融项目数,
count(distinct case when tgo.是否是供应链金融项目='是' then
               case when tgo.供应链金融状态='待激活' then tgo.org_id_new end end) 待上线项目数        
from t_gyl3_orgxx tgo
where 最近建单时间 >= to_date('2019-5-01','yyyy-mm-dd')
group by 集团）sy 
left join
(select   tgo2.集团,
count(distinct case when tgo2.是否是供应链金融项目=1 then tgo2.企业ID end) 开通供应链金融项目数,          
count(distinct case when tgo2.是否是供应链金融项目=1 then
               case when 供应链金融激活时间 is not null then tgo2.企业ID end end) 已上线项目数,                
count(distinct case when tgo2.是否是供应链金融项目=1 then
               case when tgo2.供应链金融状态 ='活跃' then tgo2.企业ID end end) 活跃,   
count(distinct case when tgo2.是否是供应链金融项目=1 then
               case when tgo2.供应链金融状态='沉默' then tgo2.企业ID end end) 沉默,    
        
count(distinct case when tgo2.是否是供应链金融项目=1 then
               case when tgo2.供应链金融状态='暂停' then tgo2.企业ID end end) 暂停 
from t_gyl3_orgxx12 tgo2  
where 最近建单时间 >= to_date('2019-5-01','yyyy-mm-dd')
group by 集团) sx on sx.集团 = sy.集团

