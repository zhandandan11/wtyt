-----------��Ŀ���Ի�����--------------�ӽ��ڷ���--����Ʊ����Ϣ------ 806  ---817����
--drop table t_gyl3_orgxx;  
create table 
t_gyl3_orgxx
as
select        
       z.DRAWEE_GROUP_NAME ����,
       z.DRAWEE ��Ʊ��,
       a.org_id ��ҵID,
       a.ORG_NAME ��ҵ����,
       sy.���Ӫ ʵʩ, 
       a.OPERATE_NAME ��Ӫ,
       p.xs �������ʱ��, 
       case
         when c.CREATED_TIME is not null and c2.CREATED_TIME is null then c.CREATED_TIME
         when c.CREATED_TIME is null and c2.CREATED_TIME is not null then c2.CREATED_TIME
         when c.CREATED_TIME is not null and c2.CREATED_TIME is not null then least(c.CREATED_TIME,c2.CREATED_TIME)
         when c.CREATED_TIME is  null and c2.CREATED_TIME is null and w3.CREATED_TIME is null then to_date('1900-01-01','yyyy-mm-dd')
         when c.CREATED_TIME is  null and c2.CREATED_TIME is null and w3.CREATED_TIME is not null then w3.CREATED_TIME  end ��Ӧ�����ڿ�ͨʱ��,
       u.PAY_TIME  ��Ӧ�����ڼ���ʱ��, 
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '��Ծ'  --��Ծ
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '��Ĭ'  --��Ĭ
         when sysdate - u1.PAY_TIME > 30 then
          '��ͣ'  --��ͣ
          when nvl(b.org_id, 0) + nvl(b1.org_id, 0) + nvl(b2.org_id, 0) +
              nvl(w.org_id, 0) > 0 and u.PAY_TIME is null then '������' ---������
          
       end ��Ӧ������״̬, -------��
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
          when (b.org_id is null and b1.org_id is null and
              b2.org_id is not null and w.org_id is not null) then
          '����2+��Э'
         when (b.org_id is not null and b1.org_id is not null and
              b2.org_id is null and w.org_id is null) then
          'Ԥ����_����1'
         when (b.org_id is not null and b1.org_id is null and
              b2.org_id is not null and w.org_id is null) then
          'Ԥ����_����2'
         when (b.org_id is null and b1.org_id is null and  b2.org_id is null and
              w.org_id is not null) then
          '��Ӧ��������Э'
       end ���ڷ���, 
       o1.yfz ��ĿԤ��������, 
       o2.dfz ��Ŀ����������,
       o.CFG_VALUE ������2˾������,
       w1.CFG_VALUE  ��Э��������,--�����ֶο�ֱ�Ӷ�Ӧ������            
       case
         when v.org_id is not null and a.IS_LOGIN_TAX = 0 then
         '��'
         else
         '��'
       end  ��Ŀ�Ƿ��Ծ, ------��Ŀ�Ƿ��Ծ
       a.OPENING_TIME ��·��ʵʩʱ��, ----��·��ʵʩʱ��
       case when a.OPENING_TIME is not null then '��' else '��' end �Ƿ�ʵʩ��·��,
       a.EXTRA_RATE �������, ----�������
       p.ns �״ν���ʱ��, ----�״ν���ʱ��
       u.PAY_TIME ����֧��ʱ��,         
       case
         when (nvl(b.org_id, 0) + nvl(b1.org_id, 0) + nvl(b2.org_id, 0) +
              nvl(w.org_id, 0) > 0) or u.PAY_TIME is not null 
          then
          '��'
         else
          '��'
       end  �Ƿ��ǹ�Ӧ��������Ŀ, ------�Ƿ��ǹ�Ӧ�������Ŀ��1-��,0-��                               
       case
         when b.org_id is not null then
          '��'
         else
          '��'
       end  �Ƿ�ͨԤ����, ------�Ƿ�ͨԤ����1-��ͨ,0-δ��ͨ
       c.CREATED_TIME Ԥ�������ÿ�ͨʱ��, ------Ԥ�������ÿ�ͨʱ��
       d.PAY_TIME Ԥ���𼤻�ʱ��, ------Ԥ���𼤻�ʱ��          
       case
         when b1.org_id is not null then
          '��'
         else
          '��'
       end �Ƿ�ͨ������1, ------�Ƿ�ͨ������1��1-��ͨ,0-δ��ͨ
       d1.PAY_TIME ������1����ʱ��, ------������1����ʱ��
       case
         when b2.org_id is not null then
          '��'
         else
          '��'
       end �Ƿ�ͨ������2, ------�Ƿ�ͨ������2��1-��ͨ,0-δ��ͨ
       c2.CREATED_TIME ������2���ÿ�ͨʱ��, ------������2���ÿ�ͨʱ��
       d2.PAY_TIME ������2����ʱ��, ------������2����ʱ��      
       t.PAY_TIME �����𼤻�ʱ��, ------�����𼤻�ʱ��     
       w2.PAY_TIME ��Э����ʱ��,--��Э����ʱ��
       w3.CREATED_TIME ��Э��ͨʱ��,--��Э��ͨʱ��
       ---case when a.TRANSFER_ID is not null then '��ת' else 'δת' end ��ת��ϵ  --TRANSFER_ID
       tor.��ת��ϵID,
       case when ztx.��ת��ϵID is not null then ztx.��ҵid else a.ORG_ID end as org_id_new 
       ---case when tor1.��ת��ϵID is not null then '��ת��Ŀ'  end as �Ƿ�ת��ϵ
  from ods.T_ORGNIZATION a-----��ҵ��Ϣ��
   left join  ods.T_TAX_DRAWEE_PARTY  z----��Ʊ������֯��ϵ��
    on z.org_id = a.org_id
  left join (select distinct ORG_ID ��ҵid,ORG_NAME ��ҵ����,TRANSFER_ID ��ת��ϵID
           from ods.T_ORGNIZATION where  TRANSFER_ID is not null) ztx on ztx.��ת��ϵID = a.ORG_ID   
    
   left join (select o.org_id,tsc.cfg_value ���Ӫ
                   from ods.t_tax_sys_cfg tsc,ods.t_orgnization o
                   where o.org_id = tsc.org_id
                   and tsc.cfg_item = '724') sy on sy.org_id = a.org_id
                   
    left join (select distinct ORG_ID ��ҵid,ORG_NAME ��ҵ����,TRANSFER_ID ��ת��ϵID from ods.T_ORGNIZATION 
where TRANSFER_ID is not null ) tor  on tor.��ҵid = a.org_id  ---�жϱ�ת��ϵ������Ŀ

--left join (select distinct ORG_ID ��ҵid,ORG_NAME ��ҵ����,TRANSFER_ID ��ת��ϵID from ods.T_ORGNIZATION 
--where TRANSFER_ID is not null ) tor1  on tor1.��ת��ϵID = a.org_id ---�жϱ�ת��ϵ�ľ�



  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG----��ҵҵ���¼���ñ�
              where CFG_ITEM = 452--��Ӧ������Ȩ��-Ԥ����
                and CFG_VALUE = 8) b
    on b.org_id = a.org_id
  left join (select org_id, min(CREATED_TIME) CREATED_TIME ----����ʱ���ⲿ�ֻ���Ҫ����ȷ�ϵ�
               from ods.T_TAX_ORG_CFG_OTIME----��ҵ�����޸�ʱ���¼��
              where IS_DEL = 0
                and OPEN_TYPE = 0
                and CFG_ITEM = 1--��Ӧ������Ȩ������
              group by org_id) c
    on c.org_id = a.org_id
  left join (select org_id, min(PAY_TIME) PAY_TIME--Ԥ���𼤻�ʱ��
               from ods.T_TAX_POS_INFO----֧����
              where PAY_way = 4--Ԥ����
                and PAY_STATE = 2--��֧��
                and IS_DEL = 0
              group by org_id) d
    on d.org_id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG ----��ҵҵ���¼���ñ�
              where CFG_ITEM = 472--˾������Ȩ��-������1
                and CFG_VALUE = 8) b1
    on b1.org_id = a.org_id
  left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----֧����
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way = 5--˾������-������1
                and tpi.PAY_STATE = 2--��֧��
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%���Ž�%' and   tpi.org_id != 373845
              group by tpi.org_id) d1
    on d1.org_id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG----��ҵҵ���¼���ñ�
              where CFG_ITEM = 479--������2Ȩ��
                and CFG_VALUE = 8
                and org_id in (select org_id
                                 from ods.T_TAX_SYS_CFG---��ҵҵ���¼���ñ�
                                where CFG_ITEM = 706--����������
                                  and CFG_VALUE = 41)) b2--��Ӧ�����ڵ�����
    on b2.org_id = a.org_id
  left join (select org_id, min(CREATED_TIME) CREATED_TIME ----����ʱ���ⲿ�ֻ���Ҫ����ȷ�ϵ�
               from ods.T_TAX_ORG_CFG_OTIME---��ҵ�����޸�ʱ���¼��
              where IS_DEL = 0
                and OPEN_TYPE = 0--����
                and CFG_ITEM = 5--������2����
              group by org_id) c2
    on c2.org_id = a.org_id
  left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----֧����
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way = 6--������2
                and tpi.PAY_STATE = 2--��֧��
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%���Ž�%' and   tpi.org_id != 373845 and   tpi.org_id != 495478 
              group by tpi.org_id) d2
    on d2.org_id = a.org_id
  left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----֧����
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (5, 6)--˾������-������1+������2
                and tpi.PAY_STATE = 2--��֧��
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%���Ž�%' and   tpi.org_id != 373845  and  tpi.org_id != 495478
              group by tpi.org_id) t
    on t.org_id = a.org_id
  left join (select tpi.org_id, min(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----֧����
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (4, 5, 6, 7)--��Ӧ������-Ԥ����+˾������-������1+������2+��Э����
                and tpi.PAY_STATE = 2--��֧��
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%���Ž�%' and   tpi.org_id != 373845  and  tpi.org_id != 495478
              group by tpi.org_id) u  --��Ӧ������---����ʱ��
    on u.org_id = a.org_id
  left join (select tpi.org_id, max(tpi.PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO tpi----֧����
               left join (select distinct org_id,ORG_NAME from ods.T_ORGNIZATION) tor on tpi.org_id = tor.org_id
              where tpi.PAY_way in (4, 5, 6, 7)--��Ӧ������-Ԥ����+˾������-������1+������2+��Э����
                and tpi.PAY_STATE = 2--��֧��
                and tpi.IS_DEL = 0
                and tor.ORG_NAME not like '%���Ž�%' and   tpi.org_id != 373845  and  tpi.org_id != 495478
              group by tpi.org_id) u1
    on u1.org_id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_POS_INFO----֧����
              where PAY_STATE = 2
                and IS_DEL = 0
                and PAY_TIME >= add_months(sysdate, -3)) v--��3�����Ƿ���֧��
    on v.org_id = a.org_id
  left join (select org_id, CFG_VALUE
               from ods.T_TAX_SYS_CFG----��ҵҵ���¼���ñ�
              where CFG_ITEM = 481) o--������˾������
    on o.org_id = a.org_id
  left join (select org_id, CFG_VALUE yfz
               from ods.T_TAX_SYS_CFG----��ҵҵ���¼���ñ�
              where CFG_ITEM = 482) o1--��Ӧ����������
    on o1.org_id = a.org_id
  left join (select org_id, CFG_VALUE dfz
               from ods.T_TAX_SYS_CFG----��ҵҵ���¼���ñ�
              where CFG_ITEM = 480) o2--��������ҵ����
    on o2.org_id = a.org_id
  left join (select org_Id, min(CREATED_TIME) ns, max(CREATED_TIME) xs--���罨��ʱ�� �������ʱ��
               from ods.T_TAX_WAYBILL----�˵���Ϣ
              where is_del = 0
              group by org_Id) p
    on p.org_Id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG----��ҵҵ���¼���ñ�
              where CFG_ITEM = 486--��Эҵ��Ȩ��
                and CFG_VALUE = 8
                and org_id in (select org_id
                                 from ods.T_TAX_SYS_CFG----��ҵҵ���¼���ñ�
                                where CFG_ITEM = 705--��Ӧ��������Э����
                                  and CFG_VALUE = 8)) w
    on w.org_Id = a.org_id
  left join (select org_id, CFG_VALUE
               from ods.T_TAX_SYS_CFG----��ҵҵ���¼���ñ�
              where CFG_ITEM = 487) w1--��Э��������
    on w1.org_id = w.org_id
  left join (select org_id, min(PAY_TIME) PAY_TIME--��Э����ʱ��
               from ods.T_TAX_POS_INFO---֧����
              where PAY_way in (7)--˾������-������1+������2
                and PAY_STATE = 2
                and IS_DEL = 0
              group by org_id) w2 on w2.org_id = w.org_id
left join ( select org_id,CREATED_TIME  --��Э��ͨʱ�䣨����ֵ��
           from ods.T_TAX_SYS_CFG 
           where  CFG_TYPE='ORGCFG' --��ҵ������Ϣ--��Э��������      
            and CFG_ITEM=487) w3 on w3.org_id = w.org_id          
 where 
    a.IS_LOGIN_TAX = 0  
    and not regexp_like(a.ORG_NAME,'����|·��|�ܳ���|���˱�|��ʾ')
    and z.DRAWEE_GROUP_NAME not like '%����%'
    and  z.DRAWEE_STATE = 1 and z.IS_DEL = 0 and z.DRAWEE_CUSTOMER_LEVEL like'A%' and a.org_id!='8380051';
   
       
--drop table t_gyl3_orgxx;  




---------------------��Ŀ������Ϣ��--------------------------------------
--select * from t_gyl3_orgxx;




--------Ԥ��+����2--����2---
-----ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
create table 
t_y_s
as
select a.org_id,min(a.PAY_TIME) PAY_TIME,min(c.CREATED_TIME) CREATED_TIME
from ods.T_TAX_POS_INFO a
left join ods.T_TAX_POS_INFO_DETAIL b on b.TAX_POS_INFO_ID=a.TAX_POS_INFO_ID
left join ods.T_TAX_WAYBILL c on c.TAX_WAYBILL_ID=b.TAX_WAYBILL_ID     -----!!!�˵���Ϣ
where a.PAY_way in (4,5,6,7)
and a.PAY_STATE=2
and a.IS_DEL=0
group by a.org_id;
         
-----drop table t_y_s;  
    
 



       
------�����𱨱�--��-200��������----------------           
select
       m.yf ��ʱ��,
       a.org_id ��ĿID,
       a.org_name ��Ŀ����,
       a2.DRAWEE_GROUP_NAME ����,             
       case
         when (b.org_id is not null and b2.org_id is not null) then
          'Ԥ����_����2'
         when (b.org_id is null and b2.org_id is not null) then
          '����2'
       end ���ڷ���,
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '��Ծ'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '��Ĭ'
         when sysdate - u1.PAY_TIME > 30 then
          '��ͣ'
         else
          '������'
       end ��Ӧ������״̬,   
       '��;' ����;,    
       sum(nvl(m.jds, 0)) ������,
       sum(nvl(m.jrds, 0)) ��Ӧ�����ڽ�����,
       sum(nvl(m.zfs, 0)) ��֧���˵���,
       sum(nvl(m.brsk, 0)) �����տ��˵���,
       sum(nvl(m.dfs, 0)) ��Ӧ�����ڵ������˵���,
       sum(nvl(m.tfs, 0)) ��ҵ2����֧������,
       sum(nvl(m.tqfs, 0)) ��ǰ�տ��˵���,
       sum(nvl(m.sjs, 0)) ��֧���˵���˾������,
       sum(nvl(m.br_sjs, 0)) �����տ�˾����,
       sum(nvl(m.df_sjs, 0)) ������֧����˾����,
       sum(nvl(m.tq_sjs, 0)) ��ǰ�տ��˵�˾����,
       sum(nvl(m.ye, 0)) Ԥ����ʹ�ý��,
       sum(nvl(m.de, 0)) ������ʹ�ý��_����˰,
       sum(nvl(m.stq, 0)) ˾����ǰ�տ���,
       sum(nvl(m.sye, 0)) �˷�,
       case
         when q.org_id is not null then
          '��'
         else
          '��'
       end ��ǰ�Ƿ�������,
       sum(nvl(m.fj_br, 0)) �ǽ���֧�������տ��˵���,
       sum(nvl(m.fj_cc, 0)) �ǽ���֧�������˵���,
       a.sale_name ����,
       a1.bu_name ����,
       u.CREATED_TIME ���ڸ��˵��״ν���ʱ��             
  from ods.T_ORGNIZATION a
  left join ods.T_TAX_DRAWEE_PARTY a2 on a.org_id=a2.org_id
  left join ods.t_m_bu a1
    on a1.bu_id = a.bu_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 452
                and CFG_VALUE = 8) b--452����Ӧ������Ȩ��-Ԥ����
    on b.org_id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 479
                and CFG_VALUE = 8
                and org_id in (select org_id
                    from ods.T_TAX_SYS_CFG
                   where CFG_ITEM = 706
                     and CFG_VALUE = 41)) b2--479��������2Ȩ��(���ų����Ž�)
    on b2.org_id = a.org_id
  left join t_y_s u        ---����ʱ��ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
    on u.org_id = a.org_id
  left join (select org_id, max(PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO
              where PAY_way in (4, 5, 6)
                and PAY_STATE = 2
                and IS_DEL = 0
              group by org_id) u1--����ʱ����Ŀ���ü�����ʱ������� ȡ��Ӧ������״̬
    on u1.org_id = a.org_id
  left join (select to_char(a.CREATED_TIME, 'IW') yf, --to_char(a.PAY_TIME,'yyyy-mm-dd')
                    a.org_id,
                    count(a.TAX_WAYBILL_ID) jds, ---������
                    count(case
                            when a.ADVANCE_PAY_STATE = 1 then--�Ƿ�渶 
                             a.tax_waybill_id
                          end) jrds, ---���ڽ�����
                    0 zfs, --֧������
                    0 brsk, --�����տ��˵���
                    0 dfs, --������֧������
                    0 tfs, --��ҵ2����֧������ 
                    0 tqfs, --��ǰ�տ��˵���
                    0 sjs, --˾���� 
                    0 br_sjs, --�����տ�˾����
                    0 df_sjs, --������֧����˾���� 
                    0 tq_sjs, --��ǰ�տ��˵�˾����
                    0 fj_br, --�ǽ���֧�������տ��˵���
                    0 fj_cc, --�ǽ���֧�������˵���
                    0 ye, --Ԥ����ʹ�ý��
                    0 de, --������ʹ�ý��_����˰
                    0 stq, --˾����ǰ�տ���
                    0 sye --�˷�  
               from ods.T_TAX_WAYBILL a
               left join t_y_s u--ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
                 on u.org_id = a.org_id
              where a.CREATED_TIME >= u.CREATED_TIME 
              and a.CREATED_TIME>=to_date('2020-7-01','yyyy-mm-dd')
              and a.CREATED_TIME<=to_date(&enddate,'yyyy-mm-dd')
                and a.MILEAGE>200   --------���ֳ���;
                and a.is_del=0
              group by to_char(a.CREATED_TIME, 'IW'), a.org_id
             union all
             select to_char(a.PAY_TIME, 'IW') yf,
                    a.org_id,
                    0 jds, ---������
                    0 jrds, ---���ڽ�����
                    count(distinct b.TAX_WAYBILL_ID) zfs, --֧������
                    count(distinct case
                            when (b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             b.TAX_WAYBILL_ID
                          end) brsk, --�����տ��˵���
                    count(distinct case
                            when a.PAY_way in (5, 6) then
                             b.TAX_WAYBILL_ID
                          end) dfs, --������֧������
                    count(distinct case
                            when (a.PAY_way in (5, 6) and
                                 ROUND(TO_NUMBER(a.PAY_TIME - c.END_TIME)) <= 2) then
                             b.TAX_WAYBILL_ID
                          end) tfs, --��ҵ2����֧������ 
                    count(distinct case
                            when (a.PAY_way in (5, 6)  and
                                 a.POS_WITHDRAWAL_WAY = 1) then
                             b.TAX_WAYBILL_ID
                          end) tqfs, --��ǰ�տ��˵���
                    count(distinct case
                            when c.id_card is not null then
                             c.id_card
                            else
                             c.mobile_no
                          end) sjs, --˾����                      
                    count(distinct case
                            when (b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) br_sjs, --�����տ�˾���� 
                    count(distinct case
                            when a.PAY_way in (5, 6) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) df_sjs, --������֧����˾���� 
                    count(distinct case
                            when (a.PAY_way in (5, 6) and
                                 a.POS_WITHDRAWAL_WAY = 1) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) tq_sjs, --��ǰ�տ��˵�˾����
                    count(distinct case
                            when (a.PAY_way not in (4, 5, 6,7) and
                                 b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             b.TAX_WAYBILL_ID
                          end) fj_br, --�ǽ���֧�������տ��˵���                              
                    count(distinct case
                            when (a.PAY_way not in (4, 5, 6,7) and
                                 ROUND(TO_NUMBER(a.PAY_TIME - c.END_TIME) * 24) > 120) then
                             b.TAX_WAYBILL_ID
                          end) fj_cc, --�ǽ���֧�������˵���
                    sum(case
                          when a.PAY_way = 4 then
                           nvl(b.ALL_FREIGHT, 0)
                        end) ye, --Ԥ����ʹ�ý��_����˰
                    sum(case
                          when a.PAY_way in (5, 6) then
                           nvl(b.ALL_FREIGHT, 0)
                        end) de, --������ʹ�ý��_����˰
                    sum(case
                          when (a.PAY_way in (4, 5, 6) and
                               a.POS_WITHDRAWAL_WAY = 1) then
                           nvl(b.ALL_FREIGHT, 0)
                        end) stq, --˾����ǰ�տ���
                    0 sye --�˷�                
               from ods.T_TAX_POS_INFO a
               left join ods.T_TAX_POS_INFO_DETAIL b
                 on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
               left join  (select distinct TAX_WAYBILL_ID,PAY_STATE,xid,MILEAGE,END_TIME,all_freight,ID_CARD,DRIVER_NAME,mobile_no from t_gyl_ydxx) c--ÿ���˵�������֧����Ϣ0729
                 on c.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID 
               left join t_y_s u--ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
                 on u.org_id = a.org_id
               left join (select WAYBILL_ID, min(CREATED_TIME) CREATED_TIME
                           from ods.T_WX_WAYBILL_RECEIPT
                          where Receipt_photo_path is not null--�ص���Ƭ·�������ϴ��ص���
                          group by WAYBILL_ID) e
                 on e.WAYBILL_ID = c.xid
              where  a.IS_DEL = 0
                and c.MILEAGE>200    -----------���ֳ���;
                and a.PAY_TIME >= u.CREATED_TIME 
                and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd') 
                and a.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')
                and a.PAY_STATE=2   -----��֧��״̬
              group by to_char(a.PAY_TIME, 'IW'), a.org_id
              union all              
              SELECT  yf, 
                      org_id,
                     0 jds, ---������
                     0 jrds, ---���ڽ�����
                     0 zfs, --֧������
                     0 brsk, --�����տ��˵���
                     0 dfs, --������֧������
                     0 tfs, --��ҵ2����֧������ 
                     0 tqfs, --��ǰ�տ��˵���
                     0 sjs, --˾���� 
                     0 br_sjs, --�����տ�˾����
                     0 df_sjs, --������֧����˾���� 
                     0 tq_sjs, --��ǰ�տ��˵�˾����
                     0 fj_br, --�ǽ���֧�������տ��˵���
                     0 fj_cc, --�ǽ���֧�������˵���
                     0 ye, --Ԥ����ʹ�ý��
                     0 de, --������ʹ�ý��_����˰
                     0 stq, --˾����ǰ�տ��� 
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
                    and a.PAY_STATE = 2 -----��֧��״̬
                    and c.MILEAGE>200         ----------���ֳ���;
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
 where b2.org_id is not null and a.org_name not like '%����%' and a.org_name not like '%��ʾ%' and a.org_name not like '%���Ž�%'
   and a1.bu_id not in (51, 52, 54, 55, 230, 601) and a2.DRAWEE_CUSTOMER_LEVEL like 'A%' and a2.DRAWEE_STATE=1 and a2.IS_DEL=0 
 group by a.org_id,
          a.org_name,
          a.sale_name,
          a1.bu_name,
          a2.DRAWEE_GROUP_NAME,
          u.CREATED_TIME,
          case
            when (b.org_id is not null and b2.org_id is not null) then
             'Ԥ����_����2'
            when (b.org_id is null and b2.org_id is not null) then
             '����2'
          end,
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '��Ծ'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '��Ĭ'
         when sysdate - u1.PAY_TIME > 30 then
          '��ͣ'
         else
          '������'
       end,
          case
            when q.org_id is not null then
             '��'
            else
             '��'
          end,
          m.yf;

------�����𱨱�--��-200��������----------------and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd')           
select
       m.yf ��ʱ��,
       a.org_id ��ĿID,
       a.org_name ��Ŀ����,
       a2.DRAWEE_GROUP_NAME ����,             
       case
         when (b.org_id is not null and b2.org_id is not null) then
          'Ԥ����_����2'
         when (b.org_id is null and b2.org_id is not null) then
          '����2'
       end ���ڷ���,
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '��Ծ'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '��Ĭ'
         when sysdate - u1.PAY_TIME > 30 then
          '��ͣ'
         else
          '������'
       end ��Ӧ������״̬,  
       '��;' ����;,      
       sum(nvl(m.jds, 0)) ������,
       sum(nvl(m.jrds, 0)) ��Ӧ�����ڽ�����,
       sum(nvl(m.zfs, 0)) ��֧���˵���,
       sum(nvl(m.brsk, 0)) �����տ��˵���,
       sum(nvl(m.dfs, 0)) ��Ӧ�����ڵ������˵���,
       sum(nvl(m.tfs, 0)) ��ҵ2����֧������,
       sum(nvl(m.tqfs, 0)) ��ǰ�տ��˵���,
       sum(nvl(m.sjs, 0)) ��֧���˵���˾������,
       sum(nvl(m.br_sjs, 0)) �����տ�˾����,
       sum(nvl(m.df_sjs, 0)) ������֧����˾����,
       sum(nvl(m.tq_sjs, 0)) ��ǰ�տ��˵�˾����,
       sum(nvl(m.ye, 0)) Ԥ����ʹ�ý��,
       sum(nvl(m.de, 0)) ������ʹ�ý��_����˰,
       sum(nvl(m.stq, 0)) ˾����ǰ�տ���,
       sum(nvl(m.sye, 0)) �˷�,
       case
         when q.org_id is not null then
          '��'
         else
          '��'
       end ��ǰ�Ƿ�������,
       sum(nvl(m.fj_br, 0)) �ǽ���֧�������տ��˵���,
       sum(nvl(m.fj_cc, 0)) �ǽ���֧�������˵���,
       a.sale_name ����,
       a1.bu_name ����,
       u.CREATED_TIME ���ڸ��˵��״ν���ʱ��             
  from ods.T_ORGNIZATION a
  left join ods.T_TAX_DRAWEE_PARTY a2 on a.org_id=a2.org_id
  left join ods.t_m_bu a1
    on a1.bu_id = a.bu_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 452
                and CFG_VALUE = 8) b--452����Ӧ������Ȩ��-Ԥ����
    on b.org_id = a.org_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 479
                and CFG_VALUE = 8
                and org_id in (select org_id
                    from ods.T_TAX_SYS_CFG
                   where CFG_ITEM = 706
                     and CFG_VALUE = 41)) b2--479��������2Ȩ��(���ų����Ž�)
    on b2.org_id = a.org_id
  left join t_y_s u        ---����ʱ��ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
    on u.org_id = a.org_id
  left join (select org_id, max(PAY_TIME) PAY_TIME
               from ods.T_TAX_POS_INFO
              where PAY_way in (4, 5, 6)
                and PAY_STATE = 2
                and IS_DEL = 0
              group by org_id) u1--����ʱ����Ŀ���ü�����ʱ������� ȡ��Ӧ������״̬
    on u1.org_id = a.org_id
  left join (select to_char(a.CREATED_TIME, 'IW') yf,
                    a.org_id,
                    count(a.TAX_WAYBILL_ID) jds, ---������
                    count(case
                            when a.ADVANCE_PAY_STATE = 1 then--�Ƿ�渶 
                             a.tax_waybill_id
                          end) jrds, ---���ڽ�����
                    0 zfs, --֧������
                    0 brsk, --�����տ��˵���
                    0 dfs, --������֧������
                    0 tfs, --��ҵ2����֧������ 
                    0 tqfs, --��ǰ�տ��˵���
                    0 sjs, --˾���� 
                    0 br_sjs, --�����տ�˾����
                    0 df_sjs, --������֧����˾���� 
                    0 tq_sjs, --��ǰ�տ��˵�˾����
                    0 fj_br, --�ǽ���֧�������տ��˵���
                    0 fj_cc, --�ǽ���֧�������˵���
                    0 ye, --Ԥ����ʹ�ý��
                    0 de, --������ʹ�ý��_����˰
                    0 stq, --˾����ǰ�տ���
                    0 sye --�˷�  
               from ods.T_TAX_WAYBILL a
               left join t_y_s u--ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
                 on u.org_id = a.org_id
              where a.CREATED_TIME >= u.CREATED_TIME 
              and a.CREATED_TIME>=to_date('2020-7-01','yyyy-mm-dd') 
              and a.CREATED_TIME<=to_date(&enddate,'yyyy-mm-dd')
                and a.MILEAGE<=200   --------���ֳ���;
                and a.is_del=0
              group by to_char(a.CREATED_TIME, 'IW'), a.org_id
             union all
             select to_char(a.PAY_TIME, 'IW') yf,
                    a.org_id,
                    0 jds, ---������
                    0 jrds, ---���ڽ�����
                    count(distinct b.TAX_WAYBILL_ID) zfs, --֧������
                    count(distinct case
                            when (b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             b.TAX_WAYBILL_ID
                          end) brsk, --�����տ��˵���
                    count(distinct case
                            when a.PAY_way in (5, 6) then
                             b.TAX_WAYBILL_ID
                          end) dfs, --������֧������
                    count(distinct case
                            when (a.PAY_way in (5, 6) and
                                 ROUND(TO_NUMBER(a.PAY_TIME - c.END_TIME)) <= 2) then
                             b.TAX_WAYBILL_ID
                          end) tfs, --��ҵ2����֧������ 
                    count(distinct case
                            when (a.PAY_way in (5, 6)  and
                                 a.POS_WITHDRAWAL_WAY = 1) then
                             b.TAX_WAYBILL_ID
                          end) tqfs, --��ǰ�տ��˵���
                    count(distinct case
                            when c.id_card is not null then
                             c.id_card
                            else
                             c.mobile_no
                          end) sjs, --˾����                      
                    count(distinct case
                            when (b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) br_sjs, --�����տ�˾���� 
                    count(distinct case
                            when a.PAY_way in (5, 6) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) df_sjs, --������֧����˾���� 
                    count(distinct case
                            when (a.PAY_way in (5, 6) and
                                 a.POS_WITHDRAWAL_WAY = 1) then
                             case
                               when c.id_card is not null then
                                c.id_card
                               else
                                c.mobile_no
                             end
                          end) tq_sjs, --��ǰ�տ��˵�˾����
                    count(distinct case
                            when (a.PAY_way not in (4, 5, 6,7) and
                                 b.REAL_NAME = c.DRIVER_NAME and
                                 b.PAYEE_ID_CARD = c.ID_CARD) then
                             b.TAX_WAYBILL_ID
                          end) fj_br, --�ǽ���֧�������տ��˵���                              
                    count(distinct case
                            when (a.PAY_way not in (4, 5, 6,7) and
                                 ROUND(TO_NUMBER(a.PAY_TIME - c.END_TIME) * 24) > 120) then
                             b.TAX_WAYBILL_ID
                          end) fj_cc, --�ǽ���֧�������˵���
                    sum(case
                          when a.PAY_way = 4 then
                           nvl(b.ALL_FREIGHT, 0)
                        end) ye, --Ԥ����ʹ�ý��_����˰
                    sum(case
                          when a.PAY_way in (5, 6) then
                           nvl(b.ALL_FREIGHT, 0)
                        end) de, --������ʹ�ý��_����˰
                    sum(case
                          when (a.PAY_way in (4, 5, 6) and
                               a.POS_WITHDRAWAL_WAY = 1) then
                           nvl(b.ALL_FREIGHT, 0)
                        end) stq, --˾����ǰ�տ���
                    0 sye --�˷�                
               from ods.T_TAX_POS_INFO a
               left join ods.T_TAX_POS_INFO_DETAIL b
                 on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
               left join (select distinct TAX_WAYBILL_ID,PAY_STATE,xid,MILEAGE,END_TIME,all_freight,ID_CARD,DRIVER_NAME,mobile_no from t_gyl_ydxx) c--ÿ���˵�������֧����Ϣ
                 on c.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID 
               left join t_y_s u--ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
                 on u.org_id = a.org_id
               left join (select WAYBILL_ID, min(CREATED_TIME) CREATED_TIME
                           from ods.T_WX_WAYBILL_RECEIPT
                          where Receipt_photo_path is not null--�ص���Ƭ·�������ϴ��ص���
                          group by WAYBILL_ID) e
                 on e.WAYBILL_ID = c.xid
              where  a.IS_DEL = 0
                and c.MILEAGE<=200    -----------���ֳ���;
                and a.PAY_TIME >= u.CREATED_TIME 
                and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd') 
                and a.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')
                and a.PAY_STATE=2   -----��֧��״̬
              group by to_char(a.PAY_TIME, 'IW'), a.org_id
              union all              
              SELECT  yf, 
                      org_id,
                     0 jds, ---������
                     0 jrds, ---���ڽ�����
                     0 zfs, --֧������
                     0 brsk, --�����տ��˵���
                     0 dfs, --������֧������
                     0 tfs, --��ҵ2����֧������ 
                     0 tqfs, --��ǰ�տ��˵���
                     0 sjs, --˾���� 
                     0 br_sjs, --�����տ�˾����
                     0 df_sjs, --������֧����˾���� 
                     0 tq_sjs, --��ǰ�տ��˵�˾����
                     0 fj_br, --�ǽ���֧�������տ��˵���
                     0 fj_cc, --�ǽ���֧�������˵���
                     0 ye, --Ԥ����ʹ�ý��
                     0 de, --������ʹ�ý��_����˰
                     0 stq, --˾����ǰ�տ��� 
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
                    and a.PAY_STATE = 2 -----��֧��״̬
                    and c.MILEAGE<=200         ----------���ֳ���;
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
 where b2.org_id is not null and a.org_name not like '%����%' and a.org_name not like '%��ʾ%' and a.org_name not like '%���Ž�%'
   and a1.bu_id not in (51, 52, 54, 55, 230, 601) and a2.DRAWEE_CUSTOMER_LEVEL like 'A%' and a2.DRAWEE_STATE=1 and a2.IS_DEL=0 
 group by a.org_id,
          a.org_name,
          a.sale_name,
          a1.bu_name,
          a2.DRAWEE_GROUP_NAME,
          u.CREATED_TIME,
          case
            when (b.org_id is not null and b2.org_id is not null) then
             'Ԥ����_����2'
            when (b.org_id is null and b2.org_id is not null) then
             '����2'
          end,
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '��Ծ'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '��Ĭ'
         when sysdate - u1.PAY_TIME > 30 then
          '��ͣ'
         else
          '������'
       end,
          case
            when q.org_id is not null then
             '��'
            else
             '��'
          end,
          m.yf;






------Ԥ���𱨱�------------------   and a.PAY_TIME>=to_date('2020-7-01','yyyy-mm-dd')         
select m.yf ��ʱ��,
       a.org_id ��ĿID,
       a.org_name ��Ŀ����,
       case
         when sysdate - u1.PAY_TIME <= 7 then
          '��Ծ'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '��Ĭ'
         when sysdate - u1.PAY_TIME > 30 then
          '��ͣ'
         else
          '������'
       end ��Ӧ������״̬,
       a2.DRAWEE_GROUP_NAME ����,
       a.operate_name ��Ӫ,            
       sum(nvl(m.jds, 0)) ������,
       sum(nvl(m.zfs, 0)) ֧������,
       sum(nvl(m.yfs, 0)) Ԥ����֧������,
       sum(nvl(m.yy, 0)) Ԥ����֧�����˷�,
       sum(nvl(m.ye, 0)) Ԥ����ʹ�ý��,
       sum(nvl(m.yds,0)) �ǽ���֧�����˵���_200����,
       a.sale_name ����,
       a1.bu_name ����,            
       u.CREATED_TIME ���ڸ��˵��״ν���ʱ��,
       case
         when q.org_id is not null then
          '��'
         else
          '��'
       end ��ǰ�Ƿ�������
  from ods.T_ORGNIZATION a
  left join ods.T_TAX_DRAWEE_PARTY a2 on a.org_id=a2.org_id
  left join ods.t_m_bu a1
    on a1.bu_id = a.bu_id
  left join (select distinct org_id
               from ods.T_TAX_SYS_CFG
              where CFG_ITEM = 452--452����Ӧ������Ȩ��-Ԥ����
                and CFG_VALUE = 8) b
    on b.org_id = a.org_id
  left join (select distinct org_id
           from ods.T_TAX_SYS_CFG 
           where CFG_ITEM=472 and CFG_VALUE=8) b1 on b1.org_id=a.org_id --472��˾������Ȩ��-������1       
  left join (select distinct org_id
           from ods.T_TAX_SYS_CFG 
           where CFG_ITEM=479 and CFG_VALUE=8) b2 on b2.org_id=a.org_id--479��������2Ȩ��
  left join t_y_s u --ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
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
                    count(a.TAX_WAYBILL_ID) jds, ---������
                    0 zfs, --֧������
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
                    0 jds, ---������
                    count(distinct b.TAX_WAYBILL_ID) zfs, --֧������            
                    count(distinct case
                            when a.PAY_way = 4 then
                             b.TAX_WAYBILL_ID
                          end) yfs, --Ԥ����֧������                          
                    sum(case
                          when a.PAY_way = 4 then
                           nvl(c.ALL_FREIGHT, 0)
                        end) yy, --Ԥ�����˵���Ӧ�˷�                        
                    sum(case
                          when a.PAY_way = 4 then
                           nvl(b.ALL_FREIGHT, 0)
                        end) ye, --Ԥ����ʹ�ý��                                       
                    count(distinct case
                            when c.MILEAGE > 200 and a.PAY_way not in (4, 5, 6,7) then
                             b.TAX_WAYBILL_ID
                          end) yds--�ǽ���֧��200���������˵���
               from ods.T_TAX_POS_INFO a
               left join ods.T_TAX_POS_INFO_DETAIL b
                 on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
               left join (select distinct TAX_WAYBILL_ID,PAY_STATE,xid,MILEAGE,END_TIME,all_freight,ID_CARD,DRIVER_NAME,mobile_no from t_gyl_ydxx) c---ÿ���˵�������֧����Ϣ
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
   and b.org_id is not null and a.org_name not like '%����%' and a.org_name not like '%��ʾ%' and a.org_name not like '%���Ž�%'
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
          '��Ծ'
         when sysdate - u1.PAY_TIME > 7 and sysdate - u1.PAY_TIME < 30 then
          '��Ĭ'
         when sysdate - u1.PAY_TIME > 30 then
          '��ͣ'
         else
          '������'
       end,
          case
            when q.org_id is not null then
             '��'
            else
             '��'
          end,
          m.yf;



--------------����--------------
select
       a.BILL_YEAR_MONTH �·�,
       a.org_id ��ҵid,
       count(a.SUPPLY_FINANCE_BILL_ID) Ӧ�������,
       count(case when a.REPAYMENT_STATE=1 and a.OVERDUE_STATE=0 then a.SUPPLY_FINANCE_BILL_ID end) �����������,
       count(case when a.OVERDUE_STATE=1 then a.SUPPLY_FINANCE_BILL_ID end) ���ڴ���,
       max( case when a.OVERDUE_STATE=1 and a.REPAYMENT_STATE=1 then a.OVERDUE_DAY
                 when a.OVERDUE_STATE=1 and a.REPAYMENT_STATE=0 then ROUND(TO_NUMBER(sysdate - a.EXPIRE_REPAYMENT_DATE))
            end ) ��������_���,
       sum(case when a.OVERDUE_STATE=1 then nvl(a.FINANCE_ALL_FREIGHT,0) end) ���ڽ��,
       sum(case when a.OVERDUE_STATE=1 and a.REPAYMENT_STATE=1 
                 then nvl(a.FINANCE_ALL_FREIGHT,0) end) �����ѻ�����
from ods.T_M_SUPPLY_FINANCE_BILL a
left join ods.T_ORGNIZATION b on b.org_id=a.org_id
where a.IS_DEL=0
and a.BILL_TYPE in (0,1,2,3)
and b.org_id in (select ��ҵID from t_gyl3_orgxx where �Ƿ��ǹ�Ӧ��������Ŀ='��')  ----��Ŀ��Ϣ��
group by a.BILL_YEAR_MONTH,
       a.org_id;
