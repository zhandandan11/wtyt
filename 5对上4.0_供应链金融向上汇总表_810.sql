--t_gyl3_orgxx��  dd807 --�ۻ������ϱ����� ���ֱ�

select jbxx.����,  
       count(distinct jbxx.��Ʊ��) �ֹ�˾��,
       count(distinct jbxx.org_id_new) ��Ŀ����,
       count(distinct case when jbxx.��Ŀ�Ƿ��Ծ = '��' then jbxx.org_id_new end) ��Ծ��Ŀ��,
       count(distinct case when  jbxx.��Ŀ�Ƿ��Ծ = '��' and zuz.opening_time is not null  then jbxx.org_id_new end) ϵͳ������Ŀ,
       zzsx.��������ʱ��,
       count(distinct case when jbxx.��Ӧ�����ڼ���ʱ�� is not null then jbxx.��Ʊ�� end) ���߷ֹ�˾��,
       count(distinct case when jbxx.��Ӧ�����ڼ���ʱ�� is not null then jbxx.org_id_new end) ������Ŀ��,  
       count(distinct case when jbxx.��Ӧ������״̬ = '��Ծ' then jbxx.��Ʊ�� end) ���ڻ�Ծ�ֹ�˾��,
       count(distinct case when jbxx.��Ӧ������״̬ = '��Ծ' then jbxx.org_id_new end) ���ڻ�Ծ��Ŀ��,
       case  when sum(nvl(d.yqe, 0)) > 0 then  '��' else '��'  end �Ƿ�������,             
       sum(nvl(e.ze, 0)) ��Ӧ�����ڽ��׶�,
       sum(nvl(e.yfe, 0)) Ԥ�����׶�,
       sum(nvl(e.dfe, 0)) �������׶�,
       sum(nvl(e.tqe, 0)) ��ǰ�տ�׶�,
       sum(nvl(e.wxe, 0)) ��Э���׶�,
       sum(nvl(e.wxt, 0)) ��Э��ǰ�տ�׶�,
       sum(nvl(e.zde, 0)) �ڴ���,
       max(d.yq_m) ��������_���, 
       sum(nvl(d.yqe, 0)) ���ڽ��  
from 
    t_gyl3_orgxx jbxx
    left join 
    ods.T_ORGNIZATION zuz on jbxx.��ҵID=zuz.org_id
    left join
     (select ����,min(��Ӧ�����ڼ���ʱ��) ��������ʱ�� from t_gyl3_orgxx where ��Ӧ�����ڼ���ʱ�� is not null --��ȡ���߹�Ӧ�����ڵļ��ż���������ʱ��
      and  NOT REGEXP_LIKE (��ҵ����, '(����|��ʾ|���Ž�|·��|���˱�|�ܳ���)') and ��ҵID !='373845' group by ���� ) zzsx--�ų��������Ž𵽸���373845 
         -- z.DRAWEE_CUSTOMER_LEVEL like'A%'   
      on zzsx.����=jbxx.����
    left join (select a.org_id,
                    max(case
                          when a.OVERDUE_STATE = 1 and a.REPAYMENT_STATE = 0 then--����״̬1: ������  ����״̬0��δ����
                           ROUND(TO_NUMBER(sysdate - a.EXPIRE_REPAYMENT_DATE)) --���ڻ�������
                        end) yq_m, ---��������_���,
                    sum(case
                          when a.OVERDUE_STATE = 1 and a.REPAYMENT_STATE = 0 then--����״̬1: ������  ����״̬0��δ����
                           nvl(a.FINANCE_ALL_FREIGHT, 0)  --��Ӧ�������ܽ��
                        end) yqe --���ڽ��,
               from ods.T_M_SUPPLY_FINANCE_BILL a
               where a.IS_DEL = 0 and a.org_id not in ('39016','163369','8357454','444889','8376278','8393852','8381021','8380051','8360288','8378340','8360230')--���̼��Ų����˺�
                and a.BILL_TYPE in (0, 1, 2, 3)--�˵����� 0�����ϣ�Ĭ��ֵ��_Ԥ���� 1��˾������_������1 2��������2 3����Э����
              group by a.org_id) d
    on d.org_id = jbxx.��ҵID
  left join (select b.org_id,
                    sum(nvl(a.PAY_ACTUAL_MONEY, 0)) ze, ---PAY_ACTUAL_MONEYʵ��֧�����--��Ӧ�����ڽ��׶�
                    sum(case
                          when b.PAY_way = 4 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) yfe, --Ԥ�����׶�
                    sum(case
                          when b.PAY_way in (5, 6) then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) dfe, --�������׶�
                    sum(case
                          when b.POS_WITHDRAWAL_WAY = 1 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) tqe, --��ǰ�տ�׶�
                    sum(case
                          when b.PAY_way = 7 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) wxe, --��Э���׶�
                    sum(case
                          when b.POS_WITHDRAWAL_WAY = 1 and b.PAY_way = 7 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) wxt, --��Э��ǰ�տ�׶�                     
                    sum(case
                          when (a.ARRIVE_TIME is not null and--����ʱ�䲻Ϊ�� ��ҵδ����
                               a.REPAYMENT_STATE = 0) then--����״̬0��δ����
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) zde --�ڴ���
               from ods.T_TAX_POS_INFO_DETAIL a
               left join ods.T_TAX_POS_INFO b
                 on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
              where b.PAY_STATE = 2 and b.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')
                and b.IS_DEL = 0
                and b.PAY_way in (4, 5, 6, 7)
              group by b.org_id) e
    on e.org_id = jbxx.��ҵID           
where  zzsx.��������ʱ�� is not null
    -- and jbxx.IS_DEL = 0
    --and jbxx.DRAWEE_CUSTOMER_LEVEL like 'A%'
    and  NOT REGEXP_LIKE (jbxx.��ҵ����, '(����|��ʾ)')
    and  exists
     (select 1
          from ods.T_TAX_WAYBILL x
         where x.is_del = 0 
           and x.created_time >= to_date('2019-05-01', 'yyyy-mm-dd')
           and x.org_id = jbxx.��ҵID)
group by jbxx.����,zzsx.��������ʱ��;



--t_gyl3_orgxx��  dd817 --��ά�ȵ����ϱ����� ���ֱ�
select jbxx.����,
       count(distinct jbxx.��Ʊ��) �ֹ�˾��,
       count(distinct jbxx.org_id_new) ��Ŀ����,
       count(distinct case when jbxx.��Ŀ�Ƿ��Ծ = '��' then jbxx.org_id_new end) ��Ծ��Ŀ��,
       count(distinct case when  jbxx.��Ŀ�Ƿ��Ծ = '��' and zuz.opening_time is not null  then jbxx.org_id_new end) ϵͳ������Ŀ,
       zzsx.��������ʱ��,
       count(distinct case when jbxx.��Ӧ�����ڼ���ʱ�� is not null then jbxx.��Ʊ�� end) ���߷ֹ�˾��,
       count(distinct case when jbxx.��Ӧ�����ڼ���ʱ�� is not null then jbxx.org_id_new end) ������Ŀ��,  
       count(distinct case when jbxx.��Ӧ������״̬ = '��Ծ' then jbxx.��Ʊ�� end) ���ڻ�Ծ�ֹ�˾��,
       count(distinct case when jbxx.��Ӧ������״̬ = '��Ծ' then jbxx.org_id_new end) ���ڻ�Ծ��Ŀ��,
       case  when sum(nvl(d.yqe, 0)) > 0 then  '��' else '��'  end �Ƿ�������, 
       sum(nvl(e1.ze, 0)) ��Ӧ�����ڽ��׶�, --�޸�             
       sum(nvl(e.ze, 0)) ��Ӧ�������ܽ��׶�,
       sum(nvl(e.yfe, 0)) Ԥ�����ܽ��׶�,
       sum(nvl(e.dfe, 0)) �������ܽ��׶�,
       sum(nvl(e.tqe, 0)) ��ǰ�տ��ܽ��׶�,
       sum(nvl(e.wxe, 0)) ��Э�ܽ��׶�,
       sum(nvl(e.wxt, 0)) ��Э��ǰ�տ��ܽ��׶�,
       sum(nvl(e1.zde, 0)) �ڴ���,
       max(d.yq_m) ��������_���, 
       sum(nvl(d.yqe, 0)) ���ڽ��  
from 
    t_gyl3_orgxx jbxx
left join ods.T_ORGNIZATION zuz on jbxx.��ҵID=zuz.org_id
left join
     (select ����,min(��Ӧ�����ڼ���ʱ��) ��������ʱ�� from t_gyl3_orgxx where ��Ӧ�����ڼ���ʱ�� is not null --��ȡ���߹�Ӧ�����ڵļ��ż���������ʱ��
      and  NOT REGEXP_LIKE (��ҵ����, '(����|��ʾ|���Ž�|·��|���˱�|�ܳ���)') and ��ҵID !='373845' group by ���� ) zzsx--�ų��������Ž𵽸���373845 
         -- z.DRAWEE_CUSTOMER_LEVEL like'A%'   
      on zzsx.����=jbxx.����
    left join (select a.org_id,
                    max(case
                          when a.OVERDUE_STATE = 1 and a.REPAYMENT_STATE = 0 then--����״̬1: ������  ����״̬0��δ����
                           ROUND(TO_NUMBER(sysdate - a.EXPIRE_REPAYMENT_DATE)) --���ڻ�������
                        end) yq_m, ---��������_���,
                    sum(case
                          when a.OVERDUE_STATE = 1 and a.REPAYMENT_STATE = 0 then--����״̬1: ������  ����״̬0��δ����
                           nvl(a.FINANCE_ALL_FREIGHT, 0)  --��Ӧ�������ܽ��
                        end) yqe --���ڽ��,
               from ods.T_M_SUPPLY_FINANCE_BILL a
               where a.IS_DEL = 0 and a.org_id not in ('39016','163369','8357454','444889','8376278','8393852','8381021','8380051','8360288','8378340','8360230')--���̼��Ų����˺�
                and a.BILL_TYPE in (0, 1, 2, 3)--�˵����� 0�����ϣ�Ĭ��ֵ��_Ԥ���� 1��˾������_������1 2��������2 3����Э���� 
              group by a.org_id) d
    on d.org_id = jbxx.��ҵID
  left join (select b.org_id,
                    sum(nvl(a.PAY_ACTUAL_MONEY, 0)) ze, ---PAY_ACTUAL_MONEYʵ��֧�����--��Ӧ�����ڽ��׶�
                    sum(case
                          when b.PAY_way = 4 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) yfe, --Ԥ�����׶�
                    sum(case
                          when b.PAY_way in (5, 6) then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) dfe, --�������׶�
                    sum(case
                          when b.POS_WITHDRAWAL_WAY = 1 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) tqe, --��ǰ�տ�׶�
                    sum(case
                          when b.PAY_way = 7 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) wxe, --��Э���׶�
                    sum(case
                          when b.POS_WITHDRAWAL_WAY = 1 and b.PAY_way = 7 then
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) wxt, --��Э��ǰ�տ�׶�                     
                    sum(case
                          when (a.ARRIVE_TIME is not null and--����ʱ�䲻Ϊ�� ��ҵδ����
                               a.REPAYMENT_STATE = 0) then--����״̬0��δ����
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) zde --�ڴ���
               from ods.T_TAX_POS_INFO_DETAIL a
               left join ods.T_TAX_POS_INFO b on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
               left join t_y_s u on u.org_id = b.org_id
              where b.PAY_STATE = 2 
                and b.IS_DEL = 0
                and b.PAY_way in (4, 5, 6, 7)
                and b.PAY_TIME > u.CREATED_TIME
                and b.PAY_TIME>=to_date(&statedate,'yyyy-mm-dd') --������ʼʱ��
                and b.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')  --�������ʱ��
              group by b.org_id) e
    on e.org_id = jbxx.��ҵID
left join (select b.org_id,
                    sum(nvl(a.PAY_ACTUAL_MONEY, 0)) ze, ---PAY_ACTUAL_MONEYʵ��֧�����--��Ӧ�����ڽ��׶�
                    sum(case
                          when (a.ARRIVE_TIME is not null and--����ʱ�䲻Ϊ�� ��ҵδ����
                               a.REPAYMENT_STATE = 0) then--����״̬0��δ����
                           nvl(a.PAY_ACTUAL_MONEY, 0)
                        end) zde --�ڴ���                   
               from ods.T_TAX_POS_INFO_DETAIL a
               left join ods.T_TAX_POS_INFO b on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
               left join t_y_s u on u.org_id = b.org_id
              where b.PAY_STATE = 2 
                and b.IS_DEL = 0
                and b.PAY_way in (4, 5, 6, 7)
                and b.PAY_TIME > u.CREATED_TIME
                and b.PAY_TIME<=to_date(&enddate,'yyyy-mm-dd')  --�������ʱ��
              group by b.org_id) e1 on e1.org_id = jbxx.��ҵID        
where  zzsx.��������ʱ�� is not null
    -- and jbxx.IS_DEL = 0
    --and jbxx.DRAWEE_CUSTOMER_LEVEL like 'A%'
    and  NOT REGEXP_LIKE (jbxx.��ҵ����, '(����|��ʾ)')
    and  exists
     (select 1
          from ods.T_TAX_WAYBILL x
         where x.is_del = 0 
           and x.created_time >= to_date('2019-05-01', 'yyyy-mm-dd')
           and x.org_id = jbxx.��ҵID)
group by jbxx.����,zzsx.��������ʱ��;



---select * from  t_gyl3_orgxx12

select sy.*,sx.*
from(select tgo.����,
count(distinct tgo.org_id_new ) ��Ŀ����,
count(distinct case when tgo.��Ŀ�Ƿ��Ծ='��' then tgo.org_id_new end) ��Ծ��Ŀ����,
count(distinct case when tgo.��Ŀ�Ƿ��Ծ='��' then 
               case when tgo.�Ƿ�ʵʩ��·��='��' then tgo.org_id_new end end) ����ϵͳδ������Ŀ��,
count(distinct case when tgo.��Ŀ�Ƿ��Ծ='��' then 
               case when tgo.�Ƿ�ʵʩ��·��='��' then tgo.org_id_new end end) ����ϵͳ������Ŀ��,
count(distinct case when tgo.�Ƿ��ǹ�Ӧ��������Ŀ='��' then tgo.org_id_new end) δ��ͨ��Ӧ��������Ŀ��,
count(distinct case when tgo.�Ƿ��ǹ�Ӧ��������Ŀ='��' then
               case when tgo.��Ӧ������״̬='������' then tgo.org_id_new end end) ��������Ŀ��        
from t_gyl3_orgxx tgo
where �������ʱ�� >= to_date('2019-5-01','yyyy-mm-dd')
group by ���ţ�sy 
left join
(select   tgo2.����,
count(distinct case when tgo2.�Ƿ��ǹ�Ӧ��������Ŀ=1 then tgo2.��ҵID end) ��ͨ��Ӧ��������Ŀ��,          
count(distinct case when tgo2.�Ƿ��ǹ�Ӧ��������Ŀ=1 then
               case when ��Ӧ�����ڼ���ʱ�� is not null then tgo2.��ҵID end end) ��������Ŀ��,                
count(distinct case when tgo2.�Ƿ��ǹ�Ӧ��������Ŀ=1 then
               case when tgo2.��Ӧ������״̬ ='��Ծ' then tgo2.��ҵID end end) ��Ծ,   
count(distinct case when tgo2.�Ƿ��ǹ�Ӧ��������Ŀ=1 then
               case when tgo2.��Ӧ������״̬='��Ĭ' then tgo2.��ҵID end end) ��Ĭ,    
        
count(distinct case when tgo2.�Ƿ��ǹ�Ӧ��������Ŀ=1 then
               case when tgo2.��Ӧ������״̬='��ͣ' then tgo2.��ҵID end end) ��ͣ 
from t_gyl3_orgxx12 tgo2  
where �������ʱ�� >= to_date('2019-5-01','yyyy-mm-dd')
group by ����) sx on sx.���� = sy.����

