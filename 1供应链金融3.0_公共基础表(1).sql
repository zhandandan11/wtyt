----------��Ŀ���ü�����ʱ�������------------
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
      case when b.org_id is not null then 1 else 0 end is_yf,  ------�Ƿ�ͨԤ����1-��ͨ,0-δ��ͨ
      c.CREATED_TIME  time_yfkt,                               ------Ԥ�������ÿ�ͨʱ��
      d.PAY_TIME  time_yfjh,                                   ------Ԥ���𼤻�ʱ��     
      case when b1.org_id is not null then 1 else 0 end is_df1,------�Ƿ�ͨ������1��1-��ͨ,0-δ��ͨ
      d1.PAY_TIME  time_df1jh,                                 ------������1����ʱ��
      case when b2.org_id is not null then 1 else 0 end is_df2,------�Ƿ�ͨ����2��1-��ͨ,0-δ��ͨ
      c2.CREATED_TIME  time_df2kt,                             ------����2���ÿ�ͨʱ��
      d2.PAY_TIME  time_df2jh,                                 ------������2����ʱ��
      t.PAY_TIME  time_dfjh,                                   ------�����𼤻�ʱ��
      u.PAY_TIME  time_jrjh,                                   ------��Ӧ�����ڼ���ʱ��(������Э)
      case
         when (b.org_id is not null and b1.org_id is null and
              b2.org_id is null and w.org_id is null) then
          'Ԥ����'
         when (b.org_id is null and b1.org_id is not null and
              b2.org_id is null and w.org_id is null) then
          '����1'
         when (b.org_id is null and b1.org_id is null and
              b2.org_id is not null and w.org_id is null) then
          '����2'
         when (b.org_id is not null and b1.org_id is not null and
              b2.org_id is null and w.org_id is null) then
          'Ԥ����_����1'
         when (b.org_id is not null and b1.org_id is null and
              b2.org_id is not null and w.org_id is null) then
          'Ԥ����_����2'
         when (b.org_id is null and b1.org_id is null and b2.org_id is null and
              w.org_id is not null) then
          '��Ӧ��������Э'
       end jfa, ---���ڷ��� 
      case when a1.DRAWEE_CUSTOMER_LEVEL like 'A%' then 'A' else 'X' end is_a,   ------�Ƿ�ΪA����Ŀ
      case when v.org_id is not null 
           and a.IS_LOGIN_TAX=0  then 1 else 0 end is_hy,      ------��Ŀ�Ƿ��Ծ
      case when nvl(b.org_id,0) + nvl(b1.org_id,0) + nvl(b2.org_id,0)+ nvl(w.org_id,0) >0 
            then 1 else 0 end is_gyl,                          ------�Ƿ��ǹ�Ӧ�������Ŀ��1-��,0-��
      o.CFG_VALUE,                                             ------������2 ˾������
      o1.yfz, ------��ĿԤ��������
      o2.dfz, ------��Ŀ���������� 
      w1.CFG_VALUE wx, ------��Э�������� 
      case when sysdate-u1.PAY_TIME<=7 then '��Ծ'
           when sysdate-u1.PAY_TIME>7 and sysdate-u1.PAY_TIME<30 then '��Ĭ'
           when sysdate-u1.PAY_TIME>30 then '��ͣ' else '������' end og_zt,   ---��Ӧ������״̬(������Э֧��)
      case when ztx.��ת��ϵID is not null then ztx.��ҵid else a.ORG_ID end as org_id_new 
from ods.T_ORGNIZATION a
inner join ods.T_TAX_DRAWEE_PARTY a1 on a.org_id=a1.org_id
left join (select distinct ORG_ID ��ҵid,ORG_NAME ��ҵ����,TRANSFER_ID ��ת��ϵID
           from ods.T_ORGNIZATION where  TRANSFER_ID is not null) ztx on ztx.��ת��ϵID = a.ORG_ID     

left join (select distinct org_id
           from ods.T_TAX_SYS_CFG 
           where CFG_ITEM=452 and CFG_VALUE=8) b on b.org_id=a.org_id--452����Ӧ������Ȩ��-Ԥ����
left join (select org_id, min(CREATED_TIME) CREATED_TIME       ----����ʱ���ⲿ�ֻ���Ҫ����ȷ�ϵ�
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
           where CFG_ITEM=472 and CFG_VALUE=8) b1 on b1.org_id=a.org_id--472��˾������Ȩ��-������1
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
                                  and CFG_VALUE = 41)) b2 on b2.org_id=a.org_id--479��������2Ȩ��(���ų����Ž�)
left join (select org_id, min(CREATED_TIME) CREATED_TIME       
           from ods.T_TAX_ORG_CFG_OTIME--��ҵ�����޸�ʱ���¼��
           where IS_DEL=0
           and OPEN_TYPE=0 
           and CFG_ITEM=5----������2����
           group by org_id) c2 on c2.org_id=a.org_id
left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----֧����
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way = 6--������2
                and tpi.PAY_STATE = 2--��֧��
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%���Ž�%' and   tpi.org_id != 373845
              group by tpi.org_id) d2 on d2.org_id=a.org_id             
left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----֧����
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (5, 6)--˾������-������1+������2
                and tpi.PAY_STATE = 2--��֧��
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%���Ž�%' and   tpi.org_id != 373845
              group by tpi.org_id) t on t.org_id=a.org_id 
left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----֧����
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (4, 5, 6, 7)--��Ӧ������-Ԥ����+˾������-������1+������2+��Э����
                and tpi.PAY_STATE = 2--��֧��
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%���Ž�%' and   tpi.org_id != 373845
              group by tpi.org_id) u on u.org_id=a.org_id
left join (select tpi.org_id, max(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----֧����
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (4, 5, 6, 7)--��Ӧ������-Ԥ����+˾������-������1+������2+��Э����
                and tpi.PAY_STATE = 2--��֧��
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%���Ž�%' and   tpi.org_id != 373845
              group by tpi.org_id) u1 on u1.org_id=a.org_id
left join (select distinct org_id 
           from ods.T_TAX_POS_INFO 
           where PAY_STATE=2
            and IS_DEL = 0
            and PAY_TIME>= add_months(sysdate,-3)) v on v.org_id=a.org_id--�����������֧��
left join (select org_id,CFG_VALUE
           from ods.T_TAX_SYS_CFG 
           where CFG_ITEM=481) o on o.org_id=a.org_id--������˾������
left join (select org_id, CFG_VALUE yfz
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 482) o1--��Ӧ����������
              on o1.org_id = a.org_id
left join (select org_id, CFG_VALUE dfz
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 480) o2--��������ҵ����
               on o2.org_id = a.org_id 
left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 486--��Эҵ��Ȩ��
                and CFG_VALUE = 8
                and org_id in (select org_id
                                 from ods.T_TAX_SYS_CFG
                                where CFG_ITEM = 705
                                  and CFG_VALUE = 8)) w--��Ӧ��������Э����
    on w.org_Id = a.org_id
left join (select org_id, CFG_VALUE
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 487) w1--��Э�������� 
                              on w1.org_id = w.org_id 
left join  ods.T_TAX_DRAWEE_PARTY  z----��Ʊ������֯��ϵ��
                          on z.org_id = a.org_id
 where 
    a.IS_LOGIN_TAX = 0 
    and not regexp_like(a.ORG_NAME,'����|·��|�ܳ���|���˱�|��ʾ') 
    and z.DRAWEE_GROUP_NAME not like '%����%'
    and  z.DRAWEE_STATE = 1 and z.IS_DEL = 0 and a.org_id!='8380051'; 
--jbxx.DRAWEE_STATE = 1         
--drop table t_gyl_orgxx;  




------------------------------�˵���Ϣ-------------------------------------
-----ÿ���˵��ս����״�֧��ʱ�䣬ĩ��֧��ʱ��
create table 
t_gyl_zj
as
select a.tax_waybill_id,
       min(b.PAY_TIME) PAY_TIME,max(b.PAY_TIME) ĩ��֧��ʱ��
from ods.T_TAX_POS_INFO_DETAIL a
inner join ods.T_TAX_POS_INFO b on b.TAX_POS_INFO_ID=a.TAX_POS_INFO_ID
left join ods.T_TAX_WAYBILL c on c.tax_waybill_id=a.tax_waybill_id
where b.PAY_STATE=2
and b.IS_DEL = 0
and b.PAY_TIME>c.END_TIME
group by a.tax_waybill_id;

--drop table t_gyl_zj;



---ÿ���˵�������֧����Ϣ
create table 
t_gyl_ydxx
as
select distinct
       a.TAX_WAYBILL_ID,
       a.org_id,
       a1.DRAWEE,     ---��Ʊ��
       a1.DRAWEE_GROUP_NAME,
       a.MOBILE_NO,--˾���ֻ���
       a.DRIVER_NAME,  ---˾������
       a.PAY_STATE, 
       a.PAID_ALL_FREIGHT,--��֧���˷ѣ�����˰��
       b.ID_CARD,--˾����һ����֤ʱ�����֤
       a.CREATED_TIME,--����ʱ��
       a.PAY_SUC_TIME ������֧��ʱ��, 
       t.HYB_RECEIVED_TIME, --���˱��ӵ�ʱ��
       f.PAY_TIME, --�ս���״�֧��ʱ�� 
       a.END_TIME, --�ս�ʱ��
       a.MILEAGE,  ---���
       a.xid,--��ص�������ֶ�
       c.vs, ---֧������
       a.ALL_FREIGHT,---------�˷�
       nvl(a.ALL_FREIGHT,0)+nvl(a.TAX_FEE,0)+nvl(a.SERVICE_FEE,0) zyf, ----�˷ѣ���˰��
       e.PAY_ACTUAL_MONEY,  ---ĩ��֧�����
       a.ADVANCE_PAY_STATE,  ---�Ƿ�渶
       a.PREPAYMENTS_OILCARD, ----Ԥ���Ϳ����        --- ����
       a.CART_BADGE_NO, -----���ƺ�
       a.CARRIER_ORG_ID -----��Э��ҵid
  from ods.T_TAX_WAYBILL a
  left join ods.T_TAX_DRAWEE_PARTY a1 on a.org_id=a1.org_id
  left join ods.T_TAX_WAYBILL_EXTRA t on t.tax_waybill_id=a.tax_waybill_id
  left join (select *
               from (select org_id,
                            MOBILE_NO, 
                            DRIVER_NAME, 
                            ID_CARD, 
                            CREATED_TIME,
                            row_number() over(partition by MOBILE_NO, DRIVER_NAME order by CREATED_TIME) rank--�ȷ������ݴ���ʱ������
                       from ods.T_M_MBAU_REC--��Ա��֤��
                      where IS_DEL = 0
                        and STATE = 1)--���ͨ��
              where rank = 1) b
    on b.MOBILE_NO = a.MOBILE_NO
   and b.DRIVER_NAME = a.DRIVER_NAME
   and b.org_id = a.org_id
  left join t_gyl_zj f on f.tax_waybill_id=a.tax_waybill_id
  left join (select a.tax_waybill_id,
                    count(a.tax_pos_info_id) vs---����(ÿ���˵�����֧���Ĵ����������˵��ս���֧������)
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





-------�˵��Ƿ����տ�-------
create table 
t_gyl_brsk
as
select  q.TAX_WAYBILL_ID --,w.PAY_TIME
  from t_gyl_ydxx q
  left join (select distinct
                    a.TAX_WAYBILL_ID,
                    a.REAL_NAME, 
                    a.PAYEE_ID_CARD, --�տ������֤��
                    b.pay_time,
                    BANK_MOBILE_NO
               from ods.T_TAX_POS_INFO_DETAIL a
               join ods.T_TAX_POS_INFO b
                 on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
              where b.PAY_STATE = 2
                and b.IS_DEL = 0 
                ---and b.PAY_TIME>=to_date('2020-03-01','yyyy-mm-dd') ---����ʱ��
                ---and b.PAY_TIME<to_date('2020-03-08','yyyy-mm-dd')
                ) w
    on w.TAX_WAYBILL_ID = q.TAX_WAYBILL_ID
 where w.REAL_NAME = q.DRIVER_NAME
 --and q.ID_CARD=w.PAYEE_ID_CARD
group by q.TAX_WAYBILL_ID ; 

--drop table t_gyl_brsk;         




---------���������˵�
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

