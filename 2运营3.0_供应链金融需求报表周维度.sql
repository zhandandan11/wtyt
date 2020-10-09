-----------项目属性基础表--------------加金融方案--加受票方信息------ 806  ---817更新
--drop table t_gyl3_orgxx;  
create table 
t_gyl3_orgxx
as
select        
       z.DRAWEE_GROUP_NAME 集团,
       z.DRAWEE 受票方,
       a.org_id 企业ID,
       a.ORG_NAME 企业名称,
       sy.深化运营 实施, 
       a.OPERATE_NAME 运营,
       p.xs 最近建单时间, 
       case
         when c.CREATED_TIME is not null and c2.CREATED_TIME is null then c.CREATED_TIME
         when c.CREATED_TIME is null and c2.CREATED_TIME is not null then c2.CREATED_TIME
         when c.CREATED_TIME is not null and c2.CREATED_TIME is not null then least(c.CREATED_TIME,c2.CREATED_TIME)
         when c.CREATED_TIME is  null and c2.CREATED_TIME is null and w3.CREATED_TIME is null then to_date('1900-01-01','yyyy-mm-dd')
         when c.CREATED_TIME is  null and c2.CREATED_TIME is null and w3.CREATED_TIME is not null then w3.CREATED_TIME  end 供应链金融开通时间,
       u.PAY_TIME  供应链金融激活时间, 
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '活跃'  --活跃
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '沉默'  --沉默
         when sysdate - u1.PAY_TIME > 30 then
          '暂停'  --暂停
          when nvl(b.org_id, 0) + nvl(b1.org_id, 0) + nvl(b2.org_id, 0) +
              nvl(w.org_id, 0) > 0 and u.PAY_TIME is null then '待激活' ---待激活
          
       end 供应链金融状态, -------改
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
          when (b.org_id is null and b1.org_id is null and
              b2.org_id is not null and w.org_id is not null) then
          '到付2+外协'
         when (b.org_id is not null and b1.org_id is not null and
              b2.org_id is null and w.org_id is null) then
          '预付金_到付1'
         when (b.org_id is not null and b1.org_id is null and
              b2.org_id is not null and w.org_id is null) then
          '预付金_到付2'
         when (b.org_id is null and b1.org_id is null and  b2.org_id is null and
              w.org_id is not null) then
          '供应链金融外协'
       end 金融方案, 
       o1.yfz 项目预付金账期, 
       o2.dfz 项目到付金账期,
       o.CFG_VALUE 到付金2司机账期,
       w1.CFG_VALUE  外协金融账期,--以上字段可直接对应档案表            
       case
         when v.org_id is not null and a.IS_LOGIN_TAX = 0 then
         '是'
         else
         '否'
       end  项目是否活跃, ------项目是否活跃
       a.OPENING_TIME 快路宝实施时间, ----快路宝实施时间
       case when a.OPENING_TIME is not null then '是' else '否' end 是否实施快路宝,
       a.EXTRA_RATE 服务费率, ----服务费率
       p.ns 首次建单时间, ----首次建单时间
       u.PAY_TIME 最早支付时间,         
       case
         when (nvl(b.org_id, 0) + nvl(b1.org_id, 0) + nvl(b2.org_id, 0) +
              nvl(w.org_id, 0) > 0) or u.PAY_TIME is not null 
          then
          '是'
         else
          '否'
       end  是否是供应链金融项目, ------是否是供应链金额项目：1-是,0-否                               
       case
         when b.org_id is not null then
          '是'
         else
          '否'
       end  是否开通预付金, ------是否开通预付金：1-开通,0-未开通
       c.CREATED_TIME 预付金配置开通时间, ------预付金配置开通时间
       d.PAY_TIME 预付金激活时间, ------预付金激活时间          
       case
         when b1.org_id is not null then
          '是'
         else
          '否'
       end 是否开通到付金1, ------是否开通到付金1：1-开通,0-未开通
       d1.PAY_TIME 到付金1激活时间, ------到付金1激活时间
       case
         when b2.org_id is not null then
          '是'
         else
          '否'
       end 是否开通到付金2, ------是否开通到付金2：1-开通,0-未开通
       c2.CREATED_TIME 到付金2配置开通时间, ------到付金2配置开通时间
       d2.PAY_TIME 到付金2激活时间, ------到付金2激活时间      
       t.PAY_TIME 到付金激活时间, ------到付金激活时间     
       w2.PAY_TIME 外协激活时间,--外协激活时间
       w3.CREATED_TIME 外协开通时间,--外协开通时间
       ---case when a.TRANSFER_ID is not null then '已转' else '未转' end 已转体系  --TRANSFER_ID
       tor.所转体系ID,
       case when ztx.所转体系ID is not null then ztx.企业id else a.ORG_ID end as org_id_new 
       ---case when tor1.所转体系ID is not null then '被转项目'  end as 是否被转体系
  from ods.T_ORGNIZATION a-----企业信息表
   left join  ods.T_TAX_DRAWEE_PARTY  z----受票方与组织关系表
    on z.org_id = a.org_id
  left join (select distinct ORG_ID 企业id,ORG_NAME 企业名称,TRANSFER_ID 所转体系ID
           from ods.T_ORGNIZATION where  TRANSFER_ID is not null) ztx on ztx.所转体系ID = a.ORG_ID   
    
   left join (select o.org_id,tsc.cfg_value 深化运营
                   from ods.t_tax_sys_cfg tsc,ods.t_orgnization o
                   where o.org_id = tsc.org_id
                   and tsc.cfg_item = '724') sy on sy.org_id = a.org_id
                   
    left join (select distinct ORG_ID 企业id,ORG_NAME 企业名称,TRANSFER_ID 所转体系ID from ods.T_ORGNIZATION 
where TRANSFER_ID is not null ) tor  on tor.企业id = a.org_id  ---判断被转体系的新项目

--left join (select distinct ORG_ID 企业id,ORG_NAME 企业名称,TRANSFER_ID 所转体系ID from ods.T_ORGNIZATION 
--where TRANSFER_ID is not null ) tor1  on tor1.所转体系ID = a.org_id ---判断被转体系的旧



  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG----企业业务记录配置表
              where CFG_ITEM = 452--供应链金融权限-预付金
                and CFG_VALUE = 8) b
    on b.org_id = a.org_id
  left join (select org_id, min(CREATED_TIME) CREATED_TIME ----配置时间这部分还是要调整确认的
               from ods.T_TAX_ORG_CFG_OTIME----企业配置修改时间记录表
              where IS_DEL = 0
                and OPEN_TYPE = 0
                and CFG_ITEM = 1--供应链金融权限配置
              group by org_id) c
    on c.org_id = a.org_id
  left join (select org_id, min(PAY_TIME) PAY_TIME--预付金激活时间
               from ods.T_TAX_POS_INFO----支付表
              where PAY_way = 4--预付金
                and PAY_STATE = 2--已支付
                and IS_DEL = 0
              group by org_id) d
    on d.org_id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG ----企业业务记录配置表
              where CFG_ITEM = 472--司机金融权限-到付金1
                and CFG_VALUE = 8) b1
    on b1.org_id = a.org_id
  left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----支付表
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way = 5--司机金融-到付金1
                and tpi.PAY_STATE = 2--已支付
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%商信金%' and   tpi.org_id != 373845
              group by tpi.org_id) d1
    on d1.org_id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG----企业业务记录配置表
              where CFG_ITEM = 479--到付金2权限
                and CFG_VALUE = 8
                and org_id in (select org_id
                                 from ods.T_TAX_SYS_CFG---企业业务记录配置表
                                where CFG_ITEM = 706--到付金类型
                                  and CFG_VALUE = 41)) b2--供应链金融到付金
    on b2.org_id = a.org_id
  left join (select org_id, min(CREATED_TIME) CREATED_TIME ----配置时间这部分还是要调整确认的
               from ods.T_TAX_ORG_CFG_OTIME---企业配置修改时间记录表
              where IS_DEL = 0
                and OPEN_TYPE = 0--开启
                and CFG_ITEM = 5--到付金2配置
              group by org_id) c2
    on c2.org_id = a.org_id
  left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----支付表
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way = 6--到付金2
                and tpi.PAY_STATE = 2--已支付
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%商信金%' and   tpi.org_id != 373845 and   tpi.org_id != 495478 
              group by tpi.org_id) d2
    on d2.org_id = a.org_id
  left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----支付表
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (5, 6)--司机金融-到付金1+到付金2
                and tpi.PAY_STATE = 2--已支付
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%商信金%' and   tpi.org_id != 373845  and  tpi.org_id != 495478
              group by tpi.org_id) t
    on t.org_id = a.org_id
  left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----支付表
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (4, 5, 6, 7)--供应链金融-预付金+司机金融-到付金1+到付金2+外协金融
                and tpi.PAY_STATE = 2--已支付
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%商信金%' and   tpi.org_id != 373845  and  tpi.org_id != 495478
              group by tpi.org_id) u  --供应链金融---激活时间
    on u.org_id = a.org_id
  left join (select tpi.org_id, max(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----支付表
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (4, 5, 6, 7)--供应链金融-预付金+司机金融-到付金1+到付金2+外协金融
                and tpi.PAY_STATE = 2--已支付
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%商信金%' and   tpi.org_id != 373845  and  tpi.org_id != 495478
              group by tpi.org_id) u1
    on u1.org_id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_POS_INFO----支付表
              where PAY_STATE = 2
                and IS_DEL = 0
                and PAY_TIME >= add_months(sysdate, -3)) v--近3个月是否有支付
    on v.org_id = a.org_id
  left join (select org_id, CFG_VALUE
               from ods.T_TAX_SYS_CFG----企业业务记录配置表
              where CFG_ITEM = 481) o--到付金司机账期
    on o.org_id = a.org_id
  left join (select org_id, CFG_VALUE yfz
               from ods.T_TAX_SYS_CFG----企业业务记录配置表
              where CFG_ITEM = 482) o1--供应链金融账期
    on o1.org_id = a.org_id
  left join (select org_id, CFG_VALUE dfz
               from ods.T_TAX_SYS_CFG----企业业务记录配置表
              where CFG_ITEM = 480) o2--到付金企业账期
    on o2.org_id = a.org_id
  left join (select org_Id, min(CREATED_TIME) ns, max(CREATED_TIME) xs--最早建单时间 最近建单时间
               from ods.T_TAX_WAYBILL----运单信息
              where is_del = 0
              group by org_Id) p
    on p.org_Id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG----企业业务记录配置表
              where CFG_ITEM = 486--外协业务权限
                and CFG_VALUE = 8
                and org_id in (select org_id
                                 from ods.T_TAX_SYS_CFG----企业业务记录配置表
                                where CFG_ITEM = 705--供应链金融外协配置
                                  and CFG_VALUE = 8)) w
    on w.org_Id = a.org_id
  left join (select org_id, CFG_VALUE
               from ods.T_TAX_SYS_CFG----企业业务记录配置表
              where CFG_ITEM = 487) w1--外协金融账期
    on w1.org_id = w.org_id
  left join (select org_id, min(PAY_TIME) PAY_TIME--外协激活时间
               from ods.T_TAX_POS_INFO---支付表
              where PAY_way in (7)--司机金融-到付金1+到付金2
                and PAY_STATE = 2
                and IS_DEL = 0
              group by org_id) w2 on w2.org_id = w.org_id
left join ( select org_id,CREATED_TIME  --外协开通时间（估计值）
           from ods.T_TAX_SYS_CFG 
           where  CFG_TYPE='ORGCFG' --企业配置信息--外协金融账期      
            and CFG_ITEM=487) w3 on w3.org_id = w.org_id          
 where 
    a.IS_LOGIN_TAX = 0  
    and not regexp_like(a.ORG_NAME,'测试|路歌|管车宝|好运宝|演示')
    and z.DRAWEE_GROUP_NAME not like '%测试%'
    and  z.DRAWEE_STATE = 1 and z.IS_DEL = 0 and z.DRAWEE_CUSTOMER_LEVEL like'A%' and a.org_id!='8380051';
   
       
--drop table t_gyl3_orgxx;  




---------------------项目基本信息表--------------------------------------
--select * from t_gyl3_orgxx;




--------预付+到付2--到付2---
-----每个项目金融付运单首次支付时间+首次建单时间
create table 
t_y_s
as
select a.org_id,min(a.PAY_TIME) PAY_TIME,min(c.CREATED_TIME) CREATED_TIME
from ods.T_TAX_POS_INFO a
left join ods.T_TAX_POS_INFO_DETAIL b on b.TAX_POS_INFO_ID=a.TAX_POS_INFO_ID
left join ods.T_TAX_WAYBILL c on c.TAX_WAYBILL_ID=b.TAX_WAYBILL_ID     -----!!!运单信息
where a.PAY_way in (4,5,6,7)
and a.PAY_STATE=2
and a.IS_DEL=0
group by a.org_id;
         
-----drop table t_y_s;  
    
 



       
------到付金报表--补-200公里以上----------------           
select
       m.yf 周时间,
       a.org_id 项目ID,
       a.org_name 项目名称,
       a2.DRAWEE_GROUP_NAME 集团,             
       case
         when (b.org_id is not null and b2.org_id is not null) then
          '预付金_到付2'
         when (b.org_id is null and b2.org_id is not null) then
          '到付2'
       end 金融方案,
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '活跃'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '沉默'
         when sysdate - u1.PAY_TIME > 30 then
          '暂停'
         else
          '待激活'
       end 供应链金融状态,   
       '长途' 长短途,    
       sum(nvl(m.jds, 0)) 建单数,
       sum(nvl(m.jrds, 0)) 供应链金融建单数,
       sum(nvl(m.zfs, 0)) 总支付运单量,
       sum(nvl(m.brsk, 0)) 本人收款运单量,
       sum(nvl(m.dfs, 0)) 供应链金融到付金运单数,
       sum(nvl(m.tfs, 0)) 企业2天内支付单数,
       sum(nvl(m.tqfs, 0)) 提前收款运单数,
       sum(nvl(m.sjs, 0)) 总支付运单中司机个数,
       sum(nvl(m.br_sjs, 0)) 本人收款司机数,
       sum(nvl(m.df_sjs, 0)) 到付金支付单司机数,
       sum(nvl(m.tq_sjs, 0)) 提前收款运单司机数,
       sum(nvl(m.ye, 0)) 预付金使用金额,
       sum(nvl(m.de, 0)) 到付金使用金额_不含税,
       sum(nvl(m.stq, 0)) 司机提前收款金额,
       sum(nvl(m.sye, 0)) 运费,
       case
         when q.org_id is not null then
          '是'
         else
          '否'
       end 当前是否有逾期,
       sum(nvl(m.fj_br, 0)) 非金融支付本人收款运单量,
       sum(nvl(m.fj_cc, 0)) 非金融支付超长运单量,
       a.sale_name 销售,
       a1.bu_name 部门,
       u.CREATED_TIME 金融付运单首次建单时间             
  from ods.T_ORGNIZATION a
  left join ods.T_TAX_DRAWEE_PARTY a2 on a.org_id=a2.org_id
  left join ods.t_m_bu a1
    on a1.bu_id = a.bu_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 452
                and CFG_VALUE = 8) b--452：供应链金融权限-预付金
    on b.org_id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 479
                and CFG_VALUE = 8
                and org_id in (select org_id
                    from ods.T_TAX_SYS_CFG
                   where CFG_ITEM = 706
                     and CFG_VALUE = 41)) b2--479：到付金2权限(已排除商信金)
    on b2.org_id = a.org_id
  left join t_y_s u        ---（临时表）每个项目金融付运单首次支付时间+首次建单时间
    on u.org_id = a.org_id
  left join (select org_id, max(PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO
              where PAY_way in (4, 5, 6)
                and PAY_STATE = 2
                and IS_DEL = 0
              group by org_id) u1--（临时表）项目配置及激活时间基础表 取供应链金融状态
    on u1.org_id = a.org_id
  left join (select to_char(a.CREATED_TIME, 'IW') yf, --to_char(a.PAY_TIME,'yyyy-mm-dd')
                    a.org_id,
                    count(a.TAX_WAYBILL_ID) jds, ---建单数
                    count(case
                            when a.ADVANCE_PAY_STATE = 1 then--是否垫付 
                             a.tax_waybill_id
                          end) jrds, ---金融建单数
                    0 zfs, --支付单量
                    0 brsk, --本人收款运单量
                    0 dfs, --到付金支付单量
                    0 tfs, --企业2天内支付单数 
                    0 tqfs, --提前收款运单数
                    0 sjs, --司机数 
                    0 br_sjs, --本人收款司机数
                    0 df_sjs, --到付金支付单司机数 
                    0 tq_sjs, --提前收款运单司机数
                    0 fj_br, --非金融支付本人收款运单量
                    0 fj_cc, --非金融支付超长运单量
                    0 ye, --预付金使用金额
                    0 de, --到付金使用金额_不含税
                    0 stq, --司机提前收款金额
                    0 sye --运费  
               from ods.T_TAX_WAYBILL a
               left join t_y_s u--每个项目金融付运单首次支付时间+首次建单时间
                 on u.org_id = a.org_id
              where a.CREATED_TIME >= u.CREATED_TIME 
              and a.CREATED_TIME>=to_date('2020-7-01','yyyy-mm-dd')
              and a.CREATED_TIME<=to_date(&enddate,'yyyy-mm-dd')
                and a.MILEAGE>200   --------区分长短途
                and a.is_del=0
              group by to_char(a.CREATED_TIME, 'IW'), a.org_id
             union all
             select to_char(a.PAY_TIME, 'IW') yf,
                    a.org_id,
                    0 jds, ---建单数
                    0 jrds, ---金融建单数
                    count(distinct b.TAX_WAYBILL_ID) zfs, --支付单量
                    count(distinct case
                            when (b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             b.TAX_WAYBILL_ID
                          end) brsk, --本人收款运单量
                    count(distinct case
                            when a.PAY_way in (5, 6) then
                             b.TAX_WAYBILL_ID
                          end) dfs, --到付金支付单量
                    count(distinct case
                            when (a.PAY_way in (5, 6) and
                                 ROUND(TO_NUMBER(a.PAY_TIME - c.END_TIME)) <= 2) then
                             b.TAX_WAYBILL_ID
                          end) tfs, --企业2天内支付单数 
                    count(distinct case
                            when (a.PAY_way in (5, 6)  and
                                 a.POS_WITHDRAWAL_WAY = 1) then
                             b.TAX_WAYBILL_ID
                          end) tqfs, --提前收款运单数
                    count(distinct case
                            when c.id_card is not null then
                             c.id_card
                            else
                             c.mobile_no
                          end) sjs, --司机数                      
                    count(distinct case
                            when (b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) br_sjs, --本人收款司机数 
                    count(distinct case
                            when a.PAY_way in (5, 6) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) df_sjs, --到付金支付单司机数 
                    count(distinct case
                            when (a.PAY_way in (5, 6) and
                                 a.POS_WITHDRAWAL_WAY = 1) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) tq_sjs, --提前收款运单司机数
                    count(distinct case
                            when (a.PAY_way not in (4, 5, 6,7) and
                                 b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             b.TAX_WAYBILL_ID
                          end) fj_br, --非金融支付本人收款运单量                              
                    count(distinct case
                            when (a.PAY_way not in (4, 5, 6,7) and
                                 ROUND(TO_NUMBER(a.PAY_TIME - c.END_TIME) * 24) > 120) then
                             b.TAX_WAYBILL_ID
                          end) fj_cc, --非金融支付超长运单量
                    sum(case
                          when a.PAY_way = 4 then
                           nvl(b.ALL_FREIGHT, 0)
                        end) ye, --预付金使用金额_不含税
                    sum(case
                          when a.PAY_way in (5, 6) then
                           nvl(b.ALL_FREIGHT, 0)
                        end) de, --到付金使用金额_不含税
                    sum(case
                          when (a.PAY_way in (4, 5, 6) and
                               a.POS_WITHDRAWAL_WAY = 1) then
                           nvl(b.ALL_FREIGHT, 0)
                        end) stq, --司机提前收款金额
                    0 sye --运费                
               from ods.T_TAX_POS_INFO a
               left join ods.T_TAX_POS_INFO_DETAIL b
                 on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
               left join  (select distinct TAX_WAYBILL_ID,PAY_STATE,xid,MILEAGE,END_TIME,all_freight,ID_CARD,DRIVER_NAME,mobile_no from t_gyl_ydxx) c--每个运单建单和支付信息0729
                 on c.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID 
               left join t_y_s u--每个项目金融付运单首次支付时间+首次建单时间
                 on u.org_id = a.org_id
               left join (select WAYBILL_ID, min(CREATED_TIME) CREATED_TIME
                           from ods.T_WX_WAYBILL_RECEIPT
                          where Receipt_photo_path is not null--回单照片路径（已上传回单）
                          group by WAYBILL_ID) e
                 on e.WAYBILL_ID = c.xid
              where  a.IS_DEL = 0
                and c.MILEAGE>200    -----------区分长短途
                and a.PAY_TIME >= u.CREATED_TIME 
                and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd') 
                and a.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')
                and a.PAY_STATE=2   -----已支付状态
              group by to_char(a.PAY_TIME, 'IW'), a.org_id
              union all              
              SELECT  yf, 
                      org_id,
                     0 jds, ---建单数
                     0 jrds, ---金融建单数
                     0 zfs, --支付单量
                     0 brsk, --本人收款运单量
                     0 dfs, --到付金支付单量
                     0 tfs, --企业2天内支付单数 
                     0 tqfs, --提前收款运单数
                     0 sjs, --司机数 
                     0 br_sjs, --本人收款司机数
                     0 df_sjs, --到付金支付单司机数 
                     0 tq_sjs, --提前收款运单司机数
                     0 fj_br, --非金融支付本人收款运单量
                     0 fj_cc, --非金融支付超长运单量
                     0 ye, --预付金使用金额
                     0 de, --到付金使用金额_不含税
                     0 stq, --司机提前收款金额 
                     sum(all_freight) syf
              FROM (SELECT distinct to_char(a.PAY_TIME, 'IW') yf,
                                    a.org_id,
                                    c.tax_waybill_id,
                                    nvl(c.all_freight, 0) all_freight
                    FROM ods.T_TAX_POS_INFO a
                    left join ods.T_TAX_POS_INFO_DETAIL b
                         on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
                    left join (select distinct TAX_WAYBILL_ID,PAY_STATE,xid,MILEAGE,END_TIME,all_freight,ID_CARD,DRIVER_NAME,mobile_no from t_gyl_ydxx) c
                         on c.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID
                    left join t_y_s u
                         on u.org_id = a.org_id
                    where  a.IS_DEL = 0
                    and a.PAY_TIME >= u.CREATED_TIME 
                    and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd')
                    and a.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')
                    and a.PAY_STATE = 2 -----已支付状态
                    and c.MILEAGE>200         ----------区分长短途
                    and a.pay_way in (4, 5, 6))
               group by yf, org_id) m
    on m.org_id = a.org_id
  left join (select a.org_id
               from ods.T_M_SUPPLY_FINANCE_BILL a
              where a.IS_DEL = 0
                and a.BILL_TYPE in (0, 1, 2)
                and a.OVERDUE_STATE = 1 and a.REPAYMENT_STATE = 0
              group by a.org_id) q
    on q.org_id = a.org_id
 where b2.org_id is not null and a.org_name not like '%测试%' and a.org_name not like '%演示%' and a.org_name not like '%商信金%'
   and a1.bu_id not in (51, 52, 54, 55, 230, 601) and a2.DRAWEE_CUSTOMER_LEVEL like 'A%' and a2.DRAWEE_STATE=1 and a2.IS_DEL=0 
 group by a.org_id,
          a.org_name,
          a.sale_name,
          a1.bu_name,
          a2.DRAWEE_GROUP_NAME,
          u.CREATED_TIME,
          case
            when (b.org_id is not null and b2.org_id is not null) then
             '预付金_到付2'
            when (b.org_id is null and b2.org_id is not null) then
             '到付2'
          end,
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '活跃'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '沉默'
         when sysdate - u1.PAY_TIME > 30 then
          '暂停'
         else
          '待激活'
       end,
          case
            when q.org_id is not null then
             '是'
            else
             '否'
          end,
          m.yf;

------到付金报表--补-200公里以内----------------and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd')           
select
       m.yf 周时间,
       a.org_id 项目ID,
       a.org_name 项目名称,
       a2.DRAWEE_GROUP_NAME 集团,             
       case
         when (b.org_id is not null and b2.org_id is not null) then
          '预付金_到付2'
         when (b.org_id is null and b2.org_id is not null) then
          '到付2'
       end 金融方案,
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '活跃'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '沉默'
         when sysdate - u1.PAY_TIME > 30 then
          '暂停'
         else
          '待激活'
       end 供应链金融状态,  
       '短途' 长短途,      
       sum(nvl(m.jds, 0)) 建单数,
       sum(nvl(m.jrds, 0)) 供应链金融建单数,
       sum(nvl(m.zfs, 0)) 总支付运单量,
       sum(nvl(m.brsk, 0)) 本人收款运单量,
       sum(nvl(m.dfs, 0)) 供应链金融到付金运单数,
       sum(nvl(m.tfs, 0)) 企业2天内支付单数,
       sum(nvl(m.tqfs, 0)) 提前收款运单数,
       sum(nvl(m.sjs, 0)) 总支付运单中司机个数,
       sum(nvl(m.br_sjs, 0)) 本人收款司机数,
       sum(nvl(m.df_sjs, 0)) 到付金支付单司机数,
       sum(nvl(m.tq_sjs, 0)) 提前收款运单司机数,
       sum(nvl(m.ye, 0)) 预付金使用金额,
       sum(nvl(m.de, 0)) 到付金使用金额_不含税,
       sum(nvl(m.stq, 0)) 司机提前收款金额,
       sum(nvl(m.sye, 0)) 运费,
       case
         when q.org_id is not null then
          '是'
         else
          '否'
       end 当前是否有逾期,
       sum(nvl(m.fj_br, 0)) 非金融支付本人收款运单量,
       sum(nvl(m.fj_cc, 0)) 非金融支付超长运单量,
       a.sale_name 销售,
       a1.bu_name 部门,
       u.CREATED_TIME 金融付运单首次建单时间             
  from ods.T_ORGNIZATION a
  left join ods.T_TAX_DRAWEE_PARTY a2 on a.org_id=a2.org_id
  left join ods.t_m_bu a1
    on a1.bu_id = a.bu_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 452
                and CFG_VALUE = 8) b--452：供应链金融权限-预付金
    on b.org_id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 479
                and CFG_VALUE = 8
                and org_id in (select org_id
                    from ods.T_TAX_SYS_CFG
                   where CFG_ITEM = 706
                     and CFG_VALUE = 41)) b2--479：到付金2权限(已排除商信金)
    on b2.org_id = a.org_id
  left join t_y_s u        ---（临时表）每个项目金融付运单首次支付时间+首次建单时间
    on u.org_id = a.org_id
  left join (select org_id, max(PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO
              where PAY_way in (4, 5, 6)
                and PAY_STATE = 2
                and IS_DEL = 0
              group by org_id) u1--（临时表）项目配置及激活时间基础表 取供应链金融状态
    on u1.org_id = a.org_id
  left join (select to_char(a.CREATED_TIME, 'IW') yf,
                    a.org_id,
                    count(a.TAX_WAYBILL_ID) jds, ---建单数
                    count(case
                            when a.ADVANCE_PAY_STATE = 1 then--是否垫付 
                             a.tax_waybill_id
                          end) jrds, ---金融建单数
                    0 zfs, --支付单量
                    0 brsk, --本人收款运单量
                    0 dfs, --到付金支付单量
                    0 tfs, --企业2天内支付单数 
                    0 tqfs, --提前收款运单数
                    0 sjs, --司机数 
                    0 br_sjs, --本人收款司机数
                    0 df_sjs, --到付金支付单司机数 
                    0 tq_sjs, --提前收款运单司机数
                    0 fj_br, --非金融支付本人收款运单量
                    0 fj_cc, --非金融支付超长运单量
                    0 ye, --预付金使用金额
                    0 de, --到付金使用金额_不含税
                    0 stq, --司机提前收款金额
                    0 sye --运费  
               from ods.T_TAX_WAYBILL a
               left join t_y_s u--每个项目金融付运单首次支付时间+首次建单时间
                 on u.org_id = a.org_id
              where a.CREATED_TIME >= u.CREATED_TIME 
              and a.CREATED_TIME>=to_date('2020-7-01','yyyy-mm-dd') 
              and a.CREATED_TIME<=to_date(&enddate,'yyyy-mm-dd')
                and a.MILEAGE<=200   --------区分长短途
                and a.is_del=0
              group by to_char(a.CREATED_TIME, 'IW'), a.org_id
             union all
             select to_char(a.PAY_TIME, 'IW') yf,
                    a.org_id,
                    0 jds, ---建单数
                    0 jrds, ---金融建单数
                    count(distinct b.TAX_WAYBILL_ID) zfs, --支付单量
                    count(distinct case
                            when (b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             b.TAX_WAYBILL_ID
                          end) brsk, --本人收款运单量
                    count(distinct case
                            when a.PAY_way in (5, 6) then
                             b.TAX_WAYBILL_ID
                          end) dfs, --到付金支付单量
                    count(distinct case
                            when (a.PAY_way in (5, 6) and
                                 ROUND(TO_NUMBER(a.PAY_TIME - c.END_TIME)) <= 2) then
                             b.TAX_WAYBILL_ID
                          end) tfs, --企业2天内支付单数 
                    count(distinct case
                            when (a.PAY_way in (5, 6)  and
                                 a.POS_WITHDRAWAL_WAY = 1) then
                             b.TAX_WAYBILL_ID
                          end) tqfs, --提前收款运单数
                    count(distinct case
                            when c.id_card is not null then
                             c.id_card
                            else
                             c.mobile_no
                          end) sjs, --司机数                      
                    count(distinct case
                            when (b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) br_sjs, --本人收款司机数 
                    count(distinct case
                            when a.PAY_way in (5, 6) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) df_sjs, --到付金支付单司机数 
                    count(distinct case
                            when (a.PAY_way in (5, 6) and
                                 a.POS_WITHDRAWAL_WAY = 1) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) tq_sjs, --提前收款运单司机数
                    count(distinct case
                            when (a.PAY_way not in (4, 5, 6,7) and
                                 b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             b.TAX_WAYBILL_ID
                          end) fj_br, --非金融支付本人收款运单量                              
                    count(distinct case
                            when (a.PAY_way not in (4, 5, 6,7) and
                                 ROUND(TO_NUMBER(a.PAY_TIME - c.END_TIME) * 24) > 120) then
                             b.TAX_WAYBILL_ID
                          end) fj_cc, --非金融支付超长运单量
                    sum(case
                          when a.PAY_way = 4 then
                           nvl(b.ALL_FREIGHT, 0)
                        end) ye, --预付金使用金额_不含税
                    sum(case
                          when a.PAY_way in (5, 6) then
                           nvl(b.ALL_FREIGHT, 0)
                        end) de, --到付金使用金额_不含税
                    sum(case
                          when (a.PAY_way in (4, 5, 6) and
                               a.POS_WITHDRAWAL_WAY = 1) then
                           nvl(b.ALL_FREIGHT, 0)
                        end) stq, --司机提前收款金额
                    0 sye --运费                
               from ods.T_TAX_POS_INFO a
               left join ods.T_TAX_POS_INFO_DETAIL b
                 on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
               left join (select distinct TAX_WAYBILL_ID,PAY_STATE,xid,MILEAGE,END_TIME,all_freight,ID_CARD,DRIVER_NAME,mobile_no from t_gyl_ydxx) c--每个运单建单和支付信息
                 on c.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID 
               left join t_y_s u--每个项目金融付运单首次支付时间+首次建单时间
                 on u.org_id = a.org_id
               left join (select WAYBILL_ID, min(CREATED_TIME) CREATED_TIME
                           from ods.T_WX_WAYBILL_RECEIPT
                          where Receipt_photo_path is not null--回单照片路径（已上传回单）
                          group by WAYBILL_ID) e
                 on e.WAYBILL_ID = c.xid
              where  a.IS_DEL = 0
                and c.MILEAGE<=200    -----------区分长短途
                and a.PAY_TIME >= u.CREATED_TIME 
                and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd') 
                and a.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')
                and a.PAY_STATE=2   -----已支付状态
              group by to_char(a.PAY_TIME, 'IW'), a.org_id
              union all              
              SELECT  yf, 
                      org_id,
                     0 jds, ---建单数
                     0 jrds, ---金融建单数
                     0 zfs, --支付单量
                     0 brsk, --本人收款运单量
                     0 dfs, --到付金支付单量
                     0 tfs, --企业2天内支付单数 
                     0 tqfs, --提前收款运单数
                     0 sjs, --司机数 
                     0 br_sjs, --本人收款司机数
                     0 df_sjs, --到付金支付单司机数 
                     0 tq_sjs, --提前收款运单司机数
                     0 fj_br, --非金融支付本人收款运单量
                     0 fj_cc, --非金融支付超长运单量
                     0 ye, --预付金使用金额
                     0 de, --到付金使用金额_不含税
                     0 stq, --司机提前收款金额 
                     sum(all_freight) syf
              FROM (SELECT distinct to_char(a.PAY_TIME, 'IW') yf,
                                    a.org_id,
                                    c.tax_waybill_id,
                                    nvl(c.all_freight, 0) all_freight
                    FROM ods.T_TAX_POS_INFO a
                    left join ods.T_TAX_POS_INFO_DETAIL b
                         on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
                    left join (select distinct TAX_WAYBILL_ID,PAY_STATE,xid,MILEAGE,END_TIME,all_freight,ID_CARD,DRIVER_NAME,mobile_no from t_gyl_ydxx) c
                         on c.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID
                    left join t_y_s u
                         on u.org_id = a.org_id
                    where  a.IS_DEL = 0
                    and a.PAY_TIME >= u.CREATED_TIME 
                    and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd') 
                    and a.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')
                    and a.PAY_STATE = 2 -----已支付状态
                    and c.MILEAGE<=200         ----------区分长短途
                    and a.pay_way in (4, 5, 6))
               group by yf, org_id) m
    on m.org_id = a.org_id
  left join (select a.org_id
               from ods.T_M_SUPPLY_FINANCE_BILL a
              where a.IS_DEL = 0
                and a.BILL_TYPE in (0, 1, 2)
                and a.OVERDUE_STATE = 1 and a.REPAYMENT_STATE = 0
              group by a.org_id) q
    on q.org_id = a.org_id
 where b2.org_id is not null and a.org_name not like '%测试%' and a.org_name not like '%演示%' and a.org_name not like '%商信金%'
   and a1.bu_id not in (51, 52, 54, 55, 230, 601) and a2.DRAWEE_CUSTOMER_LEVEL like 'A%' and a2.DRAWEE_STATE=1 and a2.IS_DEL=0 
 group by a.org_id,
          a.org_name,
          a.sale_name,
          a1.bu_name,
          a2.DRAWEE_GROUP_NAME,
          u.CREATED_TIME,
          case
            when (b.org_id is not null and b2.org_id is not null) then
             '预付金_到付2'
            when (b.org_id is null and b2.org_id is not null) then
             '到付2'
          end,
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '活跃'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '沉默'
         when sysdate - u1.PAY_TIME > 30 then
          '暂停'
         else
          '待激活'
       end,
          case
            when q.org_id is not null then
             '是'
            else
             '否'
          end,
          m.yf;






------预付金报表------------------   and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd')         
select m.yf 周时间,
       a.org_id 项目ID,
       a.org_name 项目名称,
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '活跃'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '沉默'
         when sysdate - u1.PAY_TIME > 30 then
          '暂停'
         else
          '待激活'
       end 供应链金融状态,
       a2.DRAWEE_GROUP_NAME 集团,
       a.operate_name 运营,            
       sum(nvl(m.jds, 0)) 建单数,
       sum(nvl(m.zfs, 0)) 支付单量,
       sum(nvl(m.yfs, 0)) 预付金支付单数,
       sum(nvl(m.yy, 0)) 预付金支付单运费,
       sum(nvl(m.ye, 0)) 预付金使用金额,
       sum(nvl(m.yds,0)) 非金融支付的运单数_200以上,
       a.sale_name 销售,
       a1.bu_name 部门,            
       u.CREATED_TIME 金融付运单首次建单时间,
       case
         when q.org_id is not null then
          '是'
         else
          '否'
       end 当前是否有逾期
  from ods.T_ORGNIZATION a
  left join ods.T_TAX_DRAWEE_PARTY a2 on a.org_id=a2.org_id
  left join ods.t_m_bu a1
    on a1.bu_id = a.bu_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 452--452：供应链金融权限-预付金
                and CFG_VALUE = 8) b
    on b.org_id = a.org_id
  left join (select distinct org_id
           from ods.T_TAX_SYS_CFG 
           where CFG_ITEM=472 and CFG_VALUE=8) b1 on b1.org_id=a.org_id --472：司机金融权限-到付金1       
  left join (select distinct org_id
           from ods.T_TAX_SYS_CFG 
           where CFG_ITEM=479 and CFG_VALUE=8) b2 on b2.org_id=a.org_id--479：到付金2权限
  left join t_y_s u --每个项目金融付运单首次支付时间+首次建单时间
    on u.org_id = a.org_id
  left join (select org_id, max(PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO
              where PAY_way in (4, 5, 6)
                and PAY_STATE = 2
                and IS_DEL = 0
              group by org_id) u1
    on u1.org_id = a.org_id
  left join (select to_char(a.CREATED_TIME, 'IW') yf,
                    a.org_id,
                    count(a.TAX_WAYBILL_ID) jds, ---建单数
                    0 zfs, --支付单量
                    0 yfs,
                    0 yy,
                    0 ye,
                    0 yds
               from ods.T_TAX_WAYBILL a
               left join t_y_s u
                 on u.org_id = a.org_id
              where a.CREATED_TIME >= u.CREATED_TIME 
              and a.CREATED_TIME>=to_date('2020-7-01','yyyy-mm-dd') 
              and a.CREATED_TIME<=to_date(&enddate,'yyyy-mm-dd')
              and a.is_del=0
              group by to_char(a.CREATED_TIME, 'IW'), a.org_id
             union all
             select to_char(a.PAY_TIME, 'IW') yf,
                    a.org_id,
                    0 jds, ---建单数
                    count(distinct b.TAX_WAYBILL_ID) zfs, --支付单量            
                    count(distinct case
                            when a.PAY_way = 4 then
                             b.TAX_WAYBILL_ID
                          end) yfs, --预付金支付单量                          
                    sum(case
                          when a.PAY_way = 4 then
                           nvl(c.ALL_FREIGHT, 0)
                        end) yy, --预付金运单对应运费                        
                    sum(case
                          when a.PAY_way = 4 then
                           nvl(b.ALL_FREIGHT, 0)
                        end) ye, --预付金使用金额                                       
                    count(distinct case
                            when c.MILEAGE > 200 and a.PAY_way not in (4, 5, 6,7) then
                             b.TAX_WAYBILL_ID
                          end) yds--非金融支付200公里以上运单数
               from ods.T_TAX_POS_INFO a
               left join ods.T_TAX_POS_INFO_DETAIL b
                 on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
               left join (select distinct TAX_WAYBILL_ID,PAY_STATE,xid,MILEAGE,END_TIME,all_freight,ID_CARD,DRIVER_NAME,mobile_no from t_gyl_ydxx) c---每个运单建单和支付信息
                 on c.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID 
               left join t_y_s u
                 on u.org_id = a.org_id
              where a.PAY_STATE = 2
                and a.IS_DEL = 0
                and a.PAY_TIME >= u.CREATED_TIME 
                and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd') 
                and a.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')
              group by to_char(a.PAY_TIME, 'IW'), a.org_id) m
    on m.org_id = a.org_id
  left join (select a.org_id
               from ods.T_M_SUPPLY_FINANCE_BILL a
              where a.IS_DEL = 0
                and a.BILL_TYPE in (0, 1, 2)
                and a.OVERDUE_STATE = 1
                and a.REPAYMENT_STATE = 0
              group by a.org_id) q
    on q.org_id = a.org_id
 where a.bu_id not in (51, 52, 54, 55, 230, 601)
   and b.org_id is not null and a.org_name not like '%测试%' and a.org_name not like '%演示%' and a.org_name not like '%商信金%'
   and b1.org_id is null and a2.DRAWEE_CUSTOMER_LEVEL like 'A%' and a2.DRAWEE_STATE=1 and a2.IS_DEL=0
   and b2.org_id is null
 group by a.org_id,
          a.org_name,
          a.sale_name,
          a1.bu_name,
          a2.DRAWEE_GROUP_NAME,
          a.operate_name,
          u.CREATED_TIME,
          case
         when sysdate - u1.PAY_TIME <= 7 then
          '活跃'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '沉默'
         when sysdate - u1.PAY_TIME > 30 then
          '暂停'
         else
          '待激活'
       end,
          case
            when q.org_id is not null then
             '是'
            else
             '否'
          end,
          m.yf;



--------------逾期--------------
select
       a.BILL_YEAR_MONTH 月份,
       a.org_id 企业id,
       count(a.SUPPLY_FINANCE_BILL_ID) 应还款次数,
       count(case when a.REPAYMENT_STATE=1 and a.OVERDUE_STATE=0 then a.SUPPLY_FINANCE_BILL_ID end) 正常还款次数,
       count(case when a.OVERDUE_STATE=1 then a.SUPPLY_FINANCE_BILL_ID end) 逾期次数,
       max( case when a.OVERDUE_STATE=1 and a.REPAYMENT_STATE=1 then a.OVERDUE_DAY
                 when a.OVERDUE_STATE=1 and a.REPAYMENT_STATE=0 then ROUND(TO_NUMBER(sysdate - a.EXPIRE_REPAYMENT_DATE))
            end ) 逾期天数_最大,
       sum(case when a.OVERDUE_STATE=1 then nvl(a.FINANCE_ALL_FREIGHT,0) end) 逾期金额,
       sum(case when a.OVERDUE_STATE=1 and a.REPAYMENT_STATE=1 
                 then nvl(a.FINANCE_ALL_FREIGHT,0) end) 逾期已还款金额
from ods.T_M_SUPPLY_FINANCE_BILL a
left join ods.T_ORGNIZATION b on b.org_id=a.org_id
where a.IS_DEL=0
and a.BILL_TYPE in (0,1,2,3)
and b.org_id in (select 企业ID from t_gyl3_orgxx where 是否是供应链金融项目='是')  ----项目信息表
group by a.BILL_YEAR_MONTH,
       a.org_id;
