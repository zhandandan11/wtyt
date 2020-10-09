

---drop table t_gyl3_orgxx1;  档案表新
----筛选供应链金融项目+加入被转体系id和新体系id+Q1,Q2金融占比+交付项目周期+
---这个表存在的原因是呈现最终的档案表！！1

----新企业ID,新企业id上线，则把旧企业id换掉，
----org_id_new 只要配置新企业id，则把旧企业id换掉
create table 
t_gyl3_orgxx1
as
select 
tgo.*,
case when tgo1.所转体系id is not null then tgo1.企业ID else tgo.企业ID end as 新企业ID,
case when tgo1.所转体系id is not null then '被转项目'  end as 是否被转体系,
jfz.交付达标id,
jfz.交付周期,
q2.Q2支付单,
q2.Q2金融支付单,
q2.Q2金融支付单/q2.Q2支付单  Q2金融占比,
q1.Q1支付单,  
q1.Q1金融支付单,
q1.Q1金融支付单/q1.Q1支付单  Q1金融占比
from t_gyl3_orgxx tgo
-----加入被转体系id和新体系id，tgo1.所转体系id为老id，tgo1.企业ID为新id
left join (select 企业ID,所转体系ID from t_gyl3_orgxx 
           where 所转体系ID is not null and 供应链金融激活时间 is not null
           ) tgo1  on tgo1.所转体系id = tgo.企业ID
----Q1金融支付单  有临时表  t_y_s    
                     left join (select a.org_id,
                           count(distinct case
                                   when a.PAY_way in (4, 5, 6, 7) then
                                    b.TAX_WAYBILL_ID
                                 end) Q1金融支付单,
                           count(distinct b.TAX_WAYBILL_ID) Q1支付单
                    
                      from ods.T_TAX_POS_INFO a
                      left join ods.T_TAX_POS_INFO_DETAIL b on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
                      left join t_y_s u on u.org_id = a.org_id--每个项目金融付运单首次支付时间+首次建单时间
                       left join ods.T_TAX_WAYBILL tw on tw.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID
                     where a.PAY_TIME >= u.CREATED_TIME
                       and a.PAY_TIME >= to_date('2020-04-01', 'yyyy-mm-dd')
                       and a.PAY_TIME < to_date('2020-07-01', 'yyyy-mm-dd')
                       and a.PAY_STATE=2 and a.IS_DEL = 0
                       and tw.PAY_STATE=2 and tw.IS_DEL = 0
                     group by a.org_id) q1
            on q1.org_id = tgo.企业ID
----Q1金融支付单  有临时表  t_y_s        
          left join (select tpi.org_id,
                           count(distinct case
                                   when tpi.PAY_way in (4, 5, 6, 7) then
                                    tpid.TAX_WAYBILL_ID
                                 end) Q2金融支付单,
                            count(distinct tpid.TAX_WAYBILL_ID) Q2支付单                   
                      from ods.T_TAX_POS_INFO tpi
                      left join ods.T_TAX_POS_INFO_DETAIL tpid on tpid.TAX_POS_INFO_ID = tpi.TAX_POS_INFO_ID
                      left join ods.T_TAX_WAYBILL tw on tw.TAX_WAYBILL_ID = tpid.TAX_WAYBILL_ID
                      left join t_y_s u on u.org_id = tpi.org_id--每个项目金融付运单首次支付时间+首次建单时间
                     where tpi.PAY_TIME >= u.CREATED_TIME
                       and tpi.PAY_TIME >= to_date('2020-07-01', 'yyyy-mm-dd')
                       and tpi.PAY_STATE=2 and tpi.IS_DEL = 0
                       and tw.PAY_STATE=2 and tw.IS_DEL = 0
                     group by tpi.org_id) q2
            on q2.org_id = tgo.企业ID
----交付项目             
left join(
select 交付达标id,min(交付周期) 交付周期
from
     (select jf.交付达标id,min(交付周期) 交付周期  --to_char(to_date(jr.sj,'yyyy-mm-dd')-to_date(to_char(u.PAY_TIME, 'yyyy-mm-dd'),'yyyy-mm-dd'))
      from 
      (select jr.org_id,
              case when 
              sum(jr.金融支付单) over( partition by jr.org_id ORDER BY jr.sj)/sum(jr.支付单) over( partition by jr.org_id ORDER BY jr.sj) >=0.5
              then  jr.org_id end as 交付达标id，
              case when 
              sum(jr.金融支付单) over( partition by jr.org_id ORDER BY jr.sj)/sum(jr.支付单) over( partition by jr.org_id ORDER BY jr.sj) >=0.5
              then  to_date(jr.sj,'yyyy-mm-dd')-to_date(to_char(u.PAY_TIME, 'yyyy-mm-dd'),'yyyy-mm-dd') end as 交付周期             
              from                       
                        (select a.org_id,to_char(a.PAY_TIME, 'yyyy-mm-dd') sj,--累计支付时间（天）
                           count(distinct case
                                   when a.PAY_way in (4, 5, 6, 7) then
                                    b.TAX_WAYBILL_ID
                                 end) 金融支付单,
                            count(distinct b.TAX_WAYBILL_ID) 支付单
                      from ods.T_TAX_POS_INFO a
                      left join ods.T_TAX_POS_INFO_DETAIL b on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
                      left join t_y_s u on u.org_id = a.org_id--每个项目金融付运单首次支付时间+首次建单时间
                      left join ods.T_TAX_WAYBILL tw on tw.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID
                     where a.IS_DEL = 0
                         and a.PAY_TIME <= u.PAY_TIME +30 and a.PAY_TIME >= u.PAY_TIME --and a.PAY_TIME >= u.PAY_TIME +7
                       --and a.PAY_TIME >= to_date('2020-04-01', 'yyyy-mm-dd')
                       --and a.PAY_TIME < to_date('2020-07-01', 'yyyy-mm-dd')
                       and a.PAY_STATE=2  ----已支付
                       and tw.PAY_STATE=2
                       and tw.IS_DEL = 0
                     group by a.org_id,to_char(a.PAY_TIME, 'yyyy-mm-dd') 
                     order by a.org_id,to_char(a.PAY_TIME, 'yyyy-mm-dd')
                     ) jr                    
       left join t_y_s u on u.org_id = jr.org_id
       where jr.sj >= to_char(u.PAY_TIME+7, 'yyyy-mm-dd') and sysdate >= u.PAY_TIME+7
       ) jf
      group by jf.交付达标id
      -------第七天有支付单的达标项目 -上
      -------第七天以后无支付单但是达标的项目-下
      union
      select case
         when jr.金融支付单 / jr.支付单 >= 0.5 then
          jr.org_id
       end as 交付达标id,
       7 交付周期
        from (select a.org_id,
               count(distinct case
                       when a.PAY_way in (4, 5, 6, 7) then
                        b.TAX_WAYBILL_ID
                     end) 金融支付单,
               count(distinct b.TAX_WAYBILL_ID) 支付单       
          from ods.T_TAX_POS_INFO a
          left join ods.T_TAX_POS_INFO_DETAIL b on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
          left join t_y_s u on u.org_id = a.org_id --每个项目金融付运单首次支付时间+首次建单时间
          left join ods.T_TAX_WAYBILL tw on tw.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID
         where  a.PAY_TIME <= u.PAY_TIME + 7
           and a.PAY_TIME > u.PAY_TIME
           and sysdate >= u.PAY_TIME + 7
           and a.PAY_STATE = 2
           and a.IS_DEL = 0
           and tw.PAY_STATE = 2
           and tw.IS_DEL = 0
         group by a.org_id) jr
       where jr.金融支付单 / jr.支付单 >= 0.5)
       group by 交付达标id) jfz  on jfz.交付达标id = tgo.企业id                            
where 是否是供应链金融项目='是' ---or 供应链金融激活时间 is not null                      
                          
--drop table t_gyl3_orgxx12;  

--select * from t_gyl3_orgxx1;                        
              
-------将转体的id状态与新企业id的状态融合。这个表存在的原因是计算实施和运营表！！1
create table 
t_gyl3_orgxx12
as
select
tgol.集团,
tgol.受票方,
tgol.企业ID,
tgol.企业名称,
tgol.实施,
tgol.运营,
tgo3.最近建单时间,
tgo3.首次建单时间,
tgo3.供应链金融开通时间,
tgo3.供应链金融激活时间,
tgol.供应链金融状态,
tgol.金融方案,
tgol.项目预付金账期,
tgol.项目到付金账期,
tgol.到付金2司机账期,
tgol.外协金融账期,
tgo3.项目是否活跃,
tgo3.快路宝实施时间,
tgo3.是否实施快路宝,
tgo3.是否是供应链金额项目,
tgo3.交付周期,
tgo3.Q2支付单,
tgo3.Q2金融支付单/tgo3.Q2支付单 Q2金融占比,
tgo3.Q2金融支付单,
tgo3.Q1支付单,
tgo3.Q1金融支付单,
tgo3.Q1金融支付单/tgo3.Q1支付单 Q1金融占比,
tgol.所转体系ID,
tgol.服务费率

from (select 新企业ID,
             max(最近建单时间) 最近建单时间,
             min(首次建单时间) 首次建单时间,
             min(供应链金融开通时间) 供应链金融开通时间,
             min(供应链金融激活时间) 供应链金融激活时间,
             --max(供应链金融状态) 供应链金融状态,
             ---金融方案 4
             max(case when 项目是否活跃 = '是' then 1 else 0 end) 项目是否活跃,
             min(快路宝实施时间) 快路宝实施时间,
             min(case when 是否实施快路宝 = '是' then 1 else 0 end) 是否实施快路宝,
             min(case when 是否是供应链金额项目 = '是' then 1 else 0 end) 是否是供应链金额项目,
             max(交付周期) 交付周期,
             sum(Q2支付单) Q2支付单,
             sum(Q2金融支付单) Q2金融支付单,
             sum(Q1支付单) Q1支付单,
             sum(Q1金融支付单) Q1金融支付单
             
             from t_gyl3_orgxx1
             group by 新企业ID) tgo3 ----旧企业id去掉，状态被转换到新企业id内

left join t_gyl3_orgxx1 tgol on tgo3.新企业ID = tgol.企业ID  ----新老企业id共用的状态


select * from t_gyl3_orgxx12              
              
           
