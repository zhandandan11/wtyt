

---drop table t_gyl3_orgxx1;  ��������
----ɸѡ��Ӧ��������Ŀ+���뱻ת��ϵid������ϵid+Q1,Q2����ռ��+������Ŀ����+
---�������ڵ�ԭ���ǳ������յĵ�������1

----����ҵID,����ҵid���ߣ���Ѿ���ҵid������
----org_id_new ֻҪ��������ҵid����Ѿ���ҵid����
create table 
t_gyl3_orgxx1
as
select 
tgo.*,
case when tgo1.��ת��ϵid is not null then tgo1.��ҵID else tgo.��ҵID end as ����ҵID,
case when tgo1.��ת��ϵid is not null then '��ת��Ŀ'  end as �Ƿ�ת��ϵ,
jfz.�������id,
jfz.��������,
q2.Q2֧����,
q2.Q2����֧����,
q2.Q2����֧����/q2.Q2֧����  Q2����ռ��,
q1.Q1֧����,  
q1.Q1����֧����,
q1.Q1����֧����/q1.Q1֧����  Q1����ռ��
from t_gyl3_orgxx tgo
-----���뱻ת��ϵid������ϵid��tgo1.��ת��ϵidΪ��id��tgo1.��ҵIDΪ��id
left join (select ��ҵID,��ת��ϵID from t_gyl3_orgxx 
           where ��ת��ϵID is not null and ��Ӧ�����ڼ���ʱ�� is not null
           ) tgo1  on tgo1.��ת��ϵid = tgo.��ҵID
----Q1����֧����  ����ʱ��  t_y_s    
                     left join (select a.org_id,
                           count(distinct case
                                   when a.PAY_way in (4, 5, 6, 7) then
                                    b.TAX_WAYBILL_ID
                                 end) Q1����֧����,
                           count(distinct b.TAX_WAYBILL_ID) Q1֧����
                    
                      from ods.T_TAX_POS_INFO a
                      left join ods.T_TAX_POS_INFO_DETAIL b on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
                      left join t_y_s u on u.org_id = a.org_id--ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
                       left join ods.T_TAX_WAYBILL tw on tw.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID
                     where a.PAY_TIME >= u.CREATED_TIME
                       and a.PAY_TIME >= to_date('2020-04-01', 'yyyy-mm-dd')
                       and a.PAY_TIME < to_date('2020-07-01', 'yyyy-mm-dd')
                       and a.PAY_STATE=2 and a.IS_DEL = 0
                       and tw.PAY_STATE=2 and tw.IS_DEL = 0
                     group by a.org_id) q1
            on q1.org_id = tgo.��ҵID
----Q1����֧����  ����ʱ��  t_y_s        
          left join (select tpi.org_id,
                           count(distinct case
                                   when tpi.PAY_way in (4, 5, 6, 7) then
                                    tpid.TAX_WAYBILL_ID
                                 end) Q2����֧����,
                            count(distinct tpid.TAX_WAYBILL_ID) Q2֧����                   
                      from ods.T_TAX_POS_INFO tpi
                      left join ods.T_TAX_POS_INFO_DETAIL tpid on tpid.TAX_POS_INFO_ID = tpi.TAX_POS_INFO_ID
                      left join ods.T_TAX_WAYBILL tw on tw.TAX_WAYBILL_ID = tpid.TAX_WAYBILL_ID
                      left join t_y_s u on u.org_id = tpi.org_id--ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
                     where tpi.PAY_TIME >= u.CREATED_TIME
                       and tpi.PAY_TIME >= to_date('2020-07-01', 'yyyy-mm-dd')
                       and tpi.PAY_STATE=2 and tpi.IS_DEL = 0
                       and tw.PAY_STATE=2 and tw.IS_DEL = 0
                     group by tpi.org_id) q2
            on q2.org_id = tgo.��ҵID
----������Ŀ             
left join(
select �������id,min(��������) ��������
from
     (select jf.�������id,min(��������) ��������  --to_char(to_date(jr.sj,'yyyy-mm-dd')-to_date(to_char(u.PAY_TIME, 'yyyy-mm-dd'),'yyyy-mm-dd'))
      from 
      (select jr.org_id,
              case when 
              sum(jr.����֧����) over( partition by jr.org_id ORDER BY jr.sj)/sum(jr.֧����) over( partition by jr.org_id ORDER BY jr.sj) >=0.5
              then  jr.org_id end as �������id��
              case when 
              sum(jr.����֧����) over( partition by jr.org_id ORDER BY jr.sj)/sum(jr.֧����) over( partition by jr.org_id ORDER BY jr.sj) >=0.5
              then  to_date(jr.sj,'yyyy-mm-dd')-to_date(to_char(u.PAY_TIME, 'yyyy-mm-dd'),'yyyy-mm-dd') end as ��������             
              from                       
                        (select a.org_id,to_char(a.PAY_TIME, 'yyyy-mm-dd') sj,--�ۼ�֧��ʱ�䣨�죩
                           count(distinct case
                                   when a.PAY_way in (4, 5, 6, 7) then
                                    b.TAX_WAYBILL_ID
                                 end) ����֧����,
                            count(distinct b.TAX_WAYBILL_ID) ֧����
                      from ods.T_TAX_POS_INFO a
                      left join ods.T_TAX_POS_INFO_DETAIL b on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
                      left join t_y_s u on u.org_id = a.org_id--ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
                      left join ods.T_TAX_WAYBILL tw on tw.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID
                     where a.IS_DEL = 0
                         and a.PAY_TIME <= u.PAY_TIME +30 and a.PAY_TIME >= u.PAY_TIME --and a.PAY_TIME >= u.PAY_TIME +7
                       --and a.PAY_TIME >= to_date('2020-04-01', 'yyyy-mm-dd')
                       --and a.PAY_TIME < to_date('2020-07-01', 'yyyy-mm-dd')
                       and a.PAY_STATE=2  ----��֧��
                       and tw.PAY_STATE=2
                       and tw.IS_DEL = 0
                     group by a.org_id,to_char(a.PAY_TIME, 'yyyy-mm-dd') 
                     order by a.org_id,to_char(a.PAY_TIME, 'yyyy-mm-dd')
                     ) jr                    
       left join t_y_s u on u.org_id = jr.org_id
       where jr.sj >= to_char(u.PAY_TIME+7, 'yyyy-mm-dd') and sysdate >= u.PAY_TIME+7
       ) jf
      group by jf.�������id
      -------��������֧�����Ĵ����Ŀ -��
      -------�������Ժ���֧�������Ǵ�����Ŀ-��
      union
      select case
         when jr.����֧���� / jr.֧���� >= 0.5 then
          jr.org_id
       end as �������id,
       7 ��������
        from (select a.org_id,
               count(distinct case
                       when a.PAY_way in (4, 5, 6, 7) then
                        b.TAX_WAYBILL_ID
                     end) ����֧����,
               count(distinct b.TAX_WAYBILL_ID) ֧����       
          from ods.T_TAX_POS_INFO a
          left join ods.T_TAX_POS_INFO_DETAIL b on b.TAX_POS_INFO_ID = a.TAX_POS_INFO_ID
          left join t_y_s u on u.org_id = a.org_id --ÿ����Ŀ���ڸ��˵��״�֧��ʱ��+�״ν���ʱ��
          left join ods.T_TAX_WAYBILL tw on tw.TAX_WAYBILL_ID = b.TAX_WAYBILL_ID
         where  a.PAY_TIME <= u.PAY_TIME + 7
           and a.PAY_TIME > u.PAY_TIME
           and sysdate >= u.PAY_TIME + 7
           and a.PAY_STATE = 2
           and a.IS_DEL = 0
           and tw.PAY_STATE = 2
           and tw.IS_DEL = 0
         group by a.org_id) jr
       where jr.����֧���� / jr.֧���� >= 0.5)
       group by �������id) jfz  on jfz.�������id = tgo.��ҵid                            
where �Ƿ��ǹ�Ӧ��������Ŀ='��' ---or ��Ӧ�����ڼ���ʱ�� is not null                      
                          
--drop table t_gyl3_orgxx12;  

--select * from t_gyl3_orgxx1;                        
              
-------��ת���id״̬������ҵid��״̬�ںϡ��������ڵ�ԭ���Ǽ���ʵʩ����Ӫ����1
create table 
t_gyl3_orgxx12
as
select
tgol.����,
tgol.��Ʊ��,
tgol.��ҵID,
tgol.��ҵ����,
tgol.ʵʩ,
tgol.��Ӫ,
tgo3.�������ʱ��,
tgo3.�״ν���ʱ��,
tgo3.��Ӧ�����ڿ�ͨʱ��,
tgo3.��Ӧ�����ڼ���ʱ��,
tgol.��Ӧ������״̬,
tgol.���ڷ���,
tgol.��ĿԤ��������,
tgol.��Ŀ����������,
tgol.������2˾������,
tgol.��Э��������,
tgo3.��Ŀ�Ƿ��Ծ,
tgo3.��·��ʵʩʱ��,
tgo3.�Ƿ�ʵʩ��·��,
tgo3.�Ƿ��ǹ�Ӧ�������Ŀ,
tgo3.��������,
tgo3.Q2֧����,
tgo3.Q2����֧����/tgo3.Q2֧���� Q2����ռ��,
tgo3.Q2����֧����,
tgo3.Q1֧����,
tgo3.Q1����֧����,
tgo3.Q1����֧����/tgo3.Q1֧���� Q1����ռ��,
tgol.��ת��ϵID,
tgol.�������

from (select ����ҵID,
             max(�������ʱ��) �������ʱ��,
             min(�״ν���ʱ��) �״ν���ʱ��,
             min(��Ӧ�����ڿ�ͨʱ��) ��Ӧ�����ڿ�ͨʱ��,
             min(��Ӧ�����ڼ���ʱ��) ��Ӧ�����ڼ���ʱ��,
             --max(��Ӧ������״̬) ��Ӧ������״̬,
             ---���ڷ��� 4
             max(case when ��Ŀ�Ƿ��Ծ = '��' then 1 else 0 end) ��Ŀ�Ƿ��Ծ,
             min(��·��ʵʩʱ��) ��·��ʵʩʱ��,
             min(case when �Ƿ�ʵʩ��·�� = '��' then 1 else 0 end) �Ƿ�ʵʩ��·��,
             min(case when �Ƿ��ǹ�Ӧ�������Ŀ = '��' then 1 else 0 end) �Ƿ��ǹ�Ӧ�������Ŀ,
             max(��������) ��������,
             sum(Q2֧����) Q2֧����,
             sum(Q2����֧����) Q2����֧����,
             sum(Q1֧����) Q1֧����,
             sum(Q1����֧����) Q1����֧����
             
             from t_gyl3_orgxx1
             group by ����ҵID) tgo3 ----����ҵidȥ����״̬��ת��������ҵid��

left join t_gyl3_orgxx1 tgol on tgo3.����ҵID = tgol.��ҵID  ----������ҵid���õ�״̬


select * from t_gyl3_orgxx12              
              
           
