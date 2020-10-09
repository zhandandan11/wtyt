----------项目配置及激活时间基础表------------
create table 
t_gyl_orgxx 
as
select a1.DRAWEE_GROUP_NAME,
      a1.DRAWEE_CUSTOMER_LEVEL,
      a1.DRAWEE,
      a1.DRAWEE_STATE,
      a1.IS_DEL,
      a.org_id,
      a.org_name,
      case when b.org_id is not null then 1 else 0 end is_yf,  ------是否开通预付金：1-开通,0-未开通
      c.CREATED_TIME  time_yfkt,                               ------预付金配置开通时间
      d.PAY_TIME  time_yfjh,                                   ------预付金激活时间     
      case when b1.org_id is not null then 1 else 0 end is_df1,------是否开通到付金1：1-开通,0-未开通
      d1.PAY_TIME  time_df1jh,                                 ------到付金1激活时间
      case when b2.org_id is not null then 1 else 0 end is_df2,------是否开通到付2：1-开通,0-未开通
      c2.CREATED_TIME  time_df2kt,                             ------到付2配置开通时间
      d2.PAY_TIME  time_df2jh,                                 ------到付金2激活时间
      t.PAY_TIME  time_dfjh,                                   ------到付金激活时间
      u.PAY_TIME  time_jrjh,                                   ------供应链金融激活时间(包含外协)
      case
         when (b.org_id is not null and b1.org_id is null and
              b2.org_id is null and w.org_id is null) then
          '预付金'
         when (b.org_id is null and b1.org_id is not null and
              b2.org_id is null and w.org_id is null) then
          '到付1'
         when (b.org_id is null and b1.org_id is null and
              b2.org_id is not null and w.org_id is null) then
          '到付2'
         when (b.org_id is not null and b1.org_id is not null and
              b2.org_id is null and w.org_id is null) then
          '预付金_到付1'
         when (b.org_id is not null and b1.org_id is null and
              b2.org_id is not null and w.org_id is null) then
          '预付金_到付2'
         when (b.org_id is null and b1.org_id is null and b2.org_id is null and
              w.org_id is not null) then
          '供应链金融外协'
       end jfa, ---金融方案 
      case when a1.DRAWEE_CUSTOMER_LEVEL like 'A%' then 'A' else 'X' end is_a,   ------是否为A类项目
      case when v.org_id is not null 
           and a.IS_LOGIN_TAX=0  then 1 else 0 end is_hy,      ------项目是否活跃
      case when nvl(b.org_id,0) + nvl(b1.org_id,0) + nvl(b2.org_id,0)+ nvl(w.org_id,0) >0 
            then 1 else 0 end is_gyl,                          ------是否是供应链金额项目：1-是,0-否
      o.CFG_VALUE,                                             ------到付金2 司机账期
      o1.yfz, ------项目预付金账期
      o2.dfz, ------项目到付金账期 
      w1.CFG_VALUE wx, ------外协金融账期 
      case when sysdate-u1.PAY_TIME<=7 then '活跃'
           when sysdate-u1.PAY_TIME>7 and sysdate-u1.PAY_TIME<30 then '沉默'
           when sysdate-u1.PAY_TIME>30 then '暂停' else '待激活' end og_zt,   ---供应链金融状态(包含外协支付)
      case when ztx.所转体系ID is not null then ztx.企业id else a.ORG_ID end as org_id_new 
from ods.T_ORGNIZATION a
inner join ods.T_TAX_DRAWEE_PARTY a1 on a.org_id=a1.org_id
left join (select distinct ORG_ID 企业id,ORG_NAME 企业名称,TRANSFER_ID 所转体系ID
           from ods.T_ORGNIZATION where  TRANSFER_ID is not null) ztx on ztx.所转体系ID = a.ORG_ID     

left join (select distinct org_id
           from ods.T_TAX_SYS_CFG 
           where CFG_ITEM=452 and CFG_VALUE=8) b on b.org_id=a.org_id--452：供应链金融权限-预付金
left join (select org_id, min(CREATED_TIME) CREATED_TIME       ----配置时间这部分还是要调整确认的
           from ods.T_TAX_ORG_CFG_OTIME
           where IS_DEL=0
           and OPEN_TYPE=0 
           and CFG_ITEM=1
           group by org_id) c on c.org_id=a.org_id
left join (select org_id,min(PAY_TIME) PAY_TIME
           from ods.T_TAX_POS_INFO
           where PAY_way=4
           and PAY_STATE=2
           and IS_DEL=0
           group by org_id) d on d.org_id=a.org_id         
left join (select distinct org_id
           from ods.T_TAX_SYS_CFG 
           where CFG_ITEM=472 and CFG_VALUE=8) b1 on b1.org_id=a.org_id--472：司机金融权限-到付金1
left join (select org_id,min(PAY_TIME) PAY_TIME
           from ods.T_TAX_POS_INFO
           where PAY_way=5
           and PAY_STATE=2
           and IS_DEL=0
           group by org_id) d1 on d1.org_id=a.org_id          
left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 479
                and CFG_VALUE = 8
                and org_id in (select org_id
                                 from ods.T_TAX_SYS_CFG
                                where CFG_ITEM = 706
                                  and CFG_VALUE = 41)) b2 on b2.org_id=a.org_id--479：到付金2权限(已排除商信金)
left join (select org_id, min(CREATED_TIME) CREATED_TIME       
           from ods.T_TAX_ORG_CFG_OTIME--企业配置修改时间记录表
           where IS_DEL=0
           and OPEN_TYPE=0 
           and CFG_ITEM=5----到付金2配置
           group by org_id) c2 on c2.org_id=a.org_id
left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----支付表
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way = 6--到付金2
                and tpi.PAY_STATE = 2--已支付
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%商信金%' and   tpi.org_id != 373845
              group by tpi.org_id) d2 on d2.org_id=a.org_id             
left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----支付表
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (5, 6)--司机金融-到付金1+到付金2
                and tpi.PAY_STATE = 2--已支付
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%商信金%' and   tpi.org_id != 373845
              group by tpi.org_id) t on t.org_id=a.org_id 
left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----支付表
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (4, 5, 6, 7)--供应链金融-预付金+司机金融-到付金1+到付金2+外协金融
                and tpi.PAY_STATE = 2--已支付
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%商信金%' and   tpi.org_id != 373845
              group by tpi.org_id) u on u.org_id=a.org_id
left join (select tpi.org_id, max(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----支付表
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (4, 5, 6, 7)--供应链金融-预付金+司机金融-到付金1+到付金2+外协金融
                and tpi.PAY_STATE = 2--已支付
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%商信金%' and   tpi.org_id != 373845
              group by tpi.org_id) u1 on u1.org_id=a.org_id
left join (select distinct org_id 
           from ods.T_TAX_POS_INFO 
           where PAY_STATE=2
            and IS_DEL = 0
            and PAY_TIME>= add_months(sysdate,-3)) v on v.org_id=a.org_id--最近三个月有支付
left join (select org_id,CFG_VALUE
           from ods.T_TAX_SYS_CFG 
           where CFG_ITEM=481) o on o.org_id=a.org_id--到付金司机账期
left join (select org_id, CFG_VALUE yfz
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 482) o1--供应链金融账期
              on o1.org_id = a.org_id
left join (select org_id, CFG_VALUE dfz
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 480) o2--到付金企业账期
               on o2.org_id = a.org_id 
left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 486--外协业务权限
                and CFG_VALUE = 8
                and org_id in (select org_id
                                 from ods.T_TAX_SYS_CFG
                                where CFG_ITEM = 705
                                  and CFG_VALUE = 8)) w--供应链金融外协配置
    on w.org_Id = a.org_id
left join (select org_id, CFG_VALUE
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 487) w1--外协金融账期 
                              on w1.org_id = w.org_id 
left join  ods.T_TAX_DRAWEE_PARTY  z----受票方与组织关系表
                          on z.org_id = a.org_id
 where 
    a.IS_LOGIN_TAX = 0 
    and not regexp_like(a.ORG_NAME,'测试|路歌|管车宝|好运宝|演示') 
    and z.DRAWEE_GROUP_NAME not like '%测试%'
    and  z.DRAWEE_STATE = 1 and z.IS_DEL = 0 and a.org_id!='8380051'; 
--jbxx.DRAWEE_STATE = 1         
--drop table t_gyl_orgxx;  




------------------------------运单信息-------------------------------------
-----每笔运单终结后的首次支付时间，末次支付时间
create table 
t_gyl_zj
as
select a.tax_waybill_id,
       min(b.PAY_TIME) PAY_TIME,max(b.PAY_TIME) 末次支付时间
from ods.T_TAX_POS_INFO_DETAIL a
inner join ods.T_TAX_POS_INFO b on b.TAX_POS_INFO_ID=a.TAX_POS_INFO_ID
left join ods.T_TAX_WAYBILL c on c.tax_waybill_id=a.tax_waybill_id
where b.PAY_STATE=2
and b.IS_DEL = 0
and b.PAY_TIME>c.END_TIME
group by a.tax_waybill_id;

--drop table t_gyl_zj;



---每个运单建单和支付信息
create table 
t_gyl_ydxx
as
select distinct
       a.TAX_WAYBILL_ID,
       a.org_id,
       a1.DRAWEE,     ---受票方
       a1.DRAWEE_GROUP_NAME,
       a.MOBILE_NO,--司机手机号
       a.DRIVER_NAME,  ---司机姓名
       a.PAY_STATE, 
       a.PAID_ALL_FREIGHT,--已支付运费（不含税）
       b.ID_CARD,--司机第一次认证时的身份证
       a.CREATED_TIME,--建单时间
       a.PAY_SUC_TIME 建单表支付时间, 
       t.HYB_RECEIVED_TIME, --好运宝接单时间
       f.PAY_TIME, --终结后首次支付时间 
       a.END_TIME, --终结时间
       a.MILEAGE,  ---里程
       a.xid,--与回单表关联字段
       c.vs, ---支付次数
       a.ALL_FREIGHT,---------运费
       nvl(a.ALL_FREIGHT,0)+nvl(a.TAX_FEE,0)+nvl(a.SERVICE_FEE,0) zyf, ----运费（含税）
       e.PAY_ACTUAL_MONEY,  ---末次支付金额
       a.ADVANCE_PAY_STATE,  ---是否垫付
       a.PREPAYMENTS_OILCARD, ----预付油卡金额        --- 姓名
       a.CART_BADGE_NO, -----车牌号
       a.CARRIER_ORG_ID -----外协企业id
  from ods.T_TAX_WAYBILL a
  left join ods.T_TAX_DRAWEE_PARTY a1 on a.org_id=a1.org_id
  left join ods.T_TAX_WAYBILL_EXTRA t on t.tax_waybill_id=a.tax_waybill_id
  left join (select *
               from (select org_id,
                            MOBILE_NO, 
                            DRIVER_NAME, 
                            ID_CARD, 
                            CREATED_TIME,
                            row_number() over(partition by MOBILE_NO, DRIVER_NAME order by CREATED_TIME) rank--先分组后根据创建时间排序
                       from ods.T_M_MBAU_REC--会员认证表
                      where IS_DEL = 0
                        and STATE = 1)--审核通过
              where rank = 1) b
    on b.MOBILE_NO = a.MOBILE_NO
   and b.DRIVER_NAME = a.DRIVER_NAME
   and b.org_id = a.org_id
  left join t_gyl_zj f on f.tax_waybill_id=a.tax_waybill_id
  left join (select a.tax_waybill_id,
                    count(a.tax_pos_info_id) vs---次数(每笔运单所有支付的次数，不是运单终结后的支付次数)
             from ods.T_TAX_POS_INFO_DETAIL a
             join ods.T_TAX_POS_INFO b on b.tax_pos_info_id=a.tax_pos_info_id
             where b.is_del=0
             and b.PAY_STATE=2
             group by a.tax_waybill_id
             ) c on c.tax_waybill_id=a.tax_waybill_id
  left join (select d.tax_waybill_id,
                    s.PAY_ACTUAL_MONEY
             from 
                 (select a.tax_waybill_id,
                         max(a.TAX_POS_INFO_DETAIL_ID) TAX_POS_INFO_DETAIL_ID
                  from ods.T_TAX_POS_INFO_DETAIL a
                  join ods.T_TAX_POS_INFO b
                  on b.tax_pos_info_id = a.tax_pos_info_id
                  where b.is_del = 0
                  and b.PAY_STATE = 2
                  group by a.tax_waybill_id) d
                  join ods.T_TAX_POS_INFO_DETAIL s 
                  on s.TAX_POS_INFO_DETAIL_ID=d.TAX_POS_INFO_DETAIL_ID
              )  e on e.tax_waybill_id= a.tax_waybill_id
 /* left join (select b.TAX_WAYBILL_ID, min(PAY_TIME) n_TIME
               from ods.T_TAX_POS_INFO a
               left join ods.T_TAX_POS_INFO_DETAIL b on b.TAX_POS_INFO_ID=a.TAX_POS_INFO_ID
              where PAY_way in (4, 5, 6)
                and PAY_STATE = 2
                and IS_DEL = 0
              group by b.TAX_WAYBILL_ID) u on u.TAX_WAYBILL_ID=a.TAX_WAYBILL_ID */
 where a.is_del = 0 ;


--drop table t_gyl_ydxx;   





-------运单是否本人收款-------
create table 
t_gyl_brsk
as
select  q.TAX_WAYBILL_ID --,w.PAY_TIME
  from t_gyl_ydxx q
  left join (select distinct
                    a.TAX_WAYBILL_ID,
                    a.REAL_NAME, 
                    a.PAYEE_ID_CARD, --收款人身份证号
                    b.pay_time,
                    BANK_MOBILE_NO
               from ods.T_TAX_POS_INFO_DETAIL a
               join ods.T_TAX_POS_INFO b
                 on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
              where b.PAY_STATE = 2
                and b.IS_DEL = 0 
                ---and b.PAY_TIME>=to_date('2020-03-01','yyyy-mm-dd') ---决定时间
                ---and b.PAY_TIME<to_date('2020-03-08','yyyy-mm-dd')
                ) w
    on w.TAX_WAYBILL_ID = q.TAX_WAYBILL_ID
 where w.REAL_NAME = q.DRIVER_NAME
 --and q.ID_CARD=w.PAYEE_ID_CARD
group by q.TAX_WAYBILL_ID ; 

--drop table t_gyl_brsk;         




---------超长结算运单
create table 
t_gyl_ccyd
as
select 
 distinct  a.tax_waybill_id  
from ods.T_TAX_POS_INFO_DETAIL a
left join ods.T_TAX_POS_INFO b on b.TAX_POS_INFO_ID=a.TAX_POS_INFO_ID
left join ods.T_TAX_WAYBILL c on c.tax_waybill_id=a.tax_waybill_id
and b.PAY_STATE=2
and b.IS_DEL = 0
and ROUND(TO_NUMBER(b.PAY_TIME-c.END_TIME)*24)>120;


---drop table t_gyl_ccyd;

