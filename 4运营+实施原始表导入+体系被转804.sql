---drop table   t_zdd_cs01
-- create table 
--  t_zdd_cs01
--  (��ҵID number(16),
--  ʵʩ varchar2(64),
--  ��Ӫ varchar2(64),
--   ��Ӧ�����ڿ�ͨʱ�� DATE,
--   ��Ӧ�����ڼ���ʱ�� DATE,
--   ��Ŀ�Ƿ��Ծ varchar2(64),
--   Q1����ռ�� float,
--   Q2����ռ�� float)

--select * from  t_zdd_cs01  for update;
--select * from  t_zdd_cs01 ;
------q2ʵʩ����ָ��  �� t_gyl3_orgxx ��   t_y_s  ��ʱ�� ����֮��
SELECT ʵʩ,
       COUNT(distinct ��ҵID) ��Ӧ��������Ŀ��,
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                ��ҵID
             end) ��������Ŀ��,
             
       0 ��Ŀ������,---������
       --������Ŀ��  �޸Ĵ���                                           
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null and �������� is not null
                 then
                ��ҵID
             end) ������Ŀ��,
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                 case
                  when Q2����ռ�� is not null then
                   case
                     when Q2����ռ�� < 0.5 then                
                ��ҵID
                end
                end
             end) ����δ�ﵽ����Ŀ��,             
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is  null then
                ��ҵID
             end) δ������Ŀ��,             
       count(distinct case
                  when ��Ӧ�����ڿ�ͨʱ�� >= to_date('2020-07-01', 'yyyy-mm-dd') then
                   ��ҵID
             end) �������¿�ͨ��Ŀ��,
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                case
                  when ��Ӧ�����ڼ���ʱ�� >= to_date('2020-07-01', 'yyyy-mm-dd') then
                   ��ҵID
                end
             end) ��������������Ŀ��,
       0 ������������,	--������
        --- �����Ƚ�����Ŀ�� �޸Ĵ���
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                case
                  when ��Ӧ�����ڼ���ʱ�� >= to_date('2020-07-01', 'yyyy-mm-dd') then
                    case
                  when  �������� is not null then
                   ��ҵID
                   end
                end
             end) �����Ƚ�����Ŀ��,       
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                case
                  when ��Ӧ�����ڼ���ʱ�� >= to_date('2020-07-01', 'yyyy-mm-dd') then
                   case
                     when Q2����ռ�� < 0.5 then 
                   ��ҵID
                   end
                end
             end) ����������δ�����Ŀ��, 
       count(distinct case
                  when ��Ӧ�����ڿ�ͨʱ�� >= to_date('2020-07-01', 'yyyy-mm-dd') then
                     case
                     when ��Ӧ�����ڼ���ʱ�� is  null then
                   ��ҵID
                end
             end) ������δ������Ŀ��                   
FROM t_gyl3_orgxx12
GROUP BY ʵʩ;
 
 
 
 
 -- noinspection SqlDialectInspection

SELECT ��Ӫ,
       COUNT(distinct ��ҵID) ��Ӧ��������Ŀ��,
       count(distinct case
               when ��Ŀ�Ƿ��Ծ=1 then -----'��'
                   ��ҵID
             end) ��Ծ��Ŀ��,
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                ��ҵID
             end) ������Ŀ��,  
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                case
                  when ��Ӧ�����ڼ���ʱ�� >= to_date('2020-07-01', 'yyyy-mm-dd') then
                   ��ҵID
                end
             end) ��������������Ŀ��,             
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                case
                  when ��Ӧ�����ڼ���ʱ�� >= to_date('2020-07-01', 'yyyy-mm-dd') then
                     case
                  when �������� is not null then
                   ��ҵID
                   end
                end
             end) �����Ƚ�����Ŀ��,      
       -------------�����Ƚ�����Ŀ ʵʩ������Ŀ   
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                case
                  when ��Ӧ�����ڼ���ʱ�� >= to_date('2020-07-01', 'yyyy-mm-dd') then
                   case
                     when Q2����ռ�� >= 0.5 then
                      ��ҵID
                   end
                end
             end) ���������ߴ����Ŀ��,
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                case
                  when ��Ӧ�����ڼ���ʱ�� < to_date('2020-07-01', 'yyyy-mm-dd') then
                   ��ҵID
                end
             end) �Ͽͻ���,
       count(distinct case
               when (Q1����ռ�� is not null and Q2����ռ�� is not null) then
                case
                  when Q2����ռ�� - Q1����ռ�� < 0 then
                   ��ҵID
                end
             end) �Ͽͻ�֧�ñ����½���,
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                case
                  when Q1����ռ�� is not null then
                   case
                     when Q1����ռ�� < 0.5 then
                      ��ҵID
                   end
                end
             end) Q1δ�����Ŀ��, --Q1����֧��ռ�ȵ���50%��Ŀ��
       count(distinct case
               when ��Ӧ�����ڼ���ʱ�� is not null then
                case
                  when (Q1����ռ�� is not null and Q2����ռ�� is not null) then
                   case
                     when Q1����ռ�� < 0.5 then
                      case
                        when Q2����ռ�� >= 0.5 then
                         ��ҵID
                      end
                   end
                end
             end) �Ͽͻ�����Ҵ��ͻ���
  FROM t_gyl3_orgxx12
 GROUP BY ��Ӫ;
