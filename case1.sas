LIBNAME NH 'C:\�����j���{�ɤu\�d��vcase1';RUN;
LIBNAME NH_ICD 'C:\�����j���{�ɤu\�d��vcase1\ICD';RUN;
LIBNAME  NHIRD'C:\�����j���{�ɤu\�d��vcase1';RUN;

/*�qEXCEL�ɫإ�TABLE*/
PROC IMPORT OUT = ICD9  /*��͵���ICD EXCEL�����*/
	DATAFILE = "C:\�����j���{�ɤu\�d��vcase1\ICD9��z_�e�f�X�T�{_�J��20220307.xlsx"
	DBMS = EXCEL REPLACE;
;
QUIT;

/*�qICD9Ū��pregnant��ICD�üg�J�s��table �s�bICD��Ƨ���*/
/*���ƼƦ��ño��ƭ�table�ӱư������n��case*/ 
PROC SQL;
CREATE TABLE NH_ICD.PREGNANT_ICD AS
SELECT DISTINCT
	A.ICD
FROM ICD9 AS A
WHERE 
	A.CAT LIKE 'Pregnancy'
;
QUIT;
/*��CVD��ICD*/
PROC SQL;
CREATE TABLE NH_ICD.CVD_ICD AS
SELECT DISTINCT
	A.ICD
FROM ICD9 AS A
WHERE 
	A.CAT LIKE 'Non-fatal myocardial infarction' OR
	A.CAT LIKE 'Hospotalization unstable angia' OR
	A.CAT LIKE 'Acute myocardial infarction' OR
	A.CAT LIKE 'Coronary artery disease' OR
	A.CAT LIKE 'Chronic heart failure'
;
QUIT;
/*��Malignancy��ICD*/
PROC SQL;
CREATE TABLE NH_ICD.Malignancy_ICD AS
SELECT DISTINCT
	A.ICD
FROM ICD9 AS A
WHERE 
	A.CAT LIKE 'Ovarian cancer' OR
	A.CAT LIKE 'endometrial cancer' OR
	A.CAT LIKE 'breast cancer'
;
QUIT;
/*��Ophthalmic��ICD*/
PROC SQL;
CREATE TABLE NH_ICD.Ophthalmic_ICD AS
SELECT DISTINCT
	A.ICD
FROM ICD9 AS A
WHERE 
	A.CAT LIKE 'Glaucoma' OR
	A.CAT LIKE 'Diabetic retinopathy' OR
	A.CAT LIKE 'Retinal detachment'
;
QUIT;
/*��CKD��ICD*/
PROC SQL;
CREATE TABLE NH_ICD.CKD_ICD AS
SELECT DISTINCT
	A.ICD
FROM ICD9 AS A
WHERE 
	A.CAT LIKE 'CKD'
;
QUIT;
/*��Non-spontaneous abortion(Illegal abortion)��ICD*/
PROC SQL;
CREATE TABLE NH_ICD.Non_spontaneous_abortion_ICD AS
SELECT DISTINCT
	A.ICD
FROM ICD9 AS A
WHERE 
	A.CAT LIKE 'Non-spontaneous abortion(Illegal abortion)'
;
QUIT;
/* ���ե�
���]���640 641���h��ICD���X
DATA ICD_PREGNANT; 
	INPUT ICD $;
	CARDS;
640
641
;
RUN;
*/



/*����2007~2009
ICD9CM_CODE, ICD9CM_CODE_1, ICD9CM_CODE_2, ICD9CM_CODE_3, ICD9CM_CODE_4
 ���ŦXNH.PREGNANT_ICD��ICD���H��*/
%macro read_pregnant(YEAR);
	PROC SQL;
	CREATE TABLE NH.PREGNANT_DD&YEAR AS
	SELECT DISTINCT
		A.ID,
		CATS(A.ID_BIRTHDAY,'15') AS ID_BIRTHDAY, /*�N�ͤ�]��15��  ��ƫ��A��YYMMDD8.*/
		A.IN_DATE, 
		FLOOR(
			YRDIF(
				INPUT(CATS(A.ID_BIRTHDAY,'15'),YYMMDD8.),
				INPUT(A.IN_DATE,YYMMDD8.),
			'ACT/ACT')
		) AS AGE,
		A.ICD9CM_CODE,
		A.ICD9CM_CODE_1,
		A.ICD9CM_CODE_2,
		A.ICD9CM_CODE_3,
		A.ICD9CM_CODE_4    /*��������ICD ID ID�ͤ� �J�|��� �o8��*/
	FROM NH.DD&YEAR  AS A
	WHERE 
		ICD9CM_CODE IN (SELECT ICD FROM NH_ICD.PREGNANT_ICD) OR
		ICD9CM_CODE_1 IN (SELECT ICD FROM NH_ICD.PREGNANT_ICD) OR
		ICD9CM_CODE_2 IN (SELECT ICD FROM NH_ICD.PREGNANT_ICD) OR
		ICD9CM_CODE_3 IN (SELECT ICD FROM NH_ICD.PREGNANT_ICD) OR
		ICD9CM_CODE_4 IN (SELECT ICD FROM NH_ICD.PREGNANT_ICD) 
	;
	QUIT;
%mend;
%macro read_cd_pregnant(YEAR);
	PROC SQL;
	CREATE TABLE NH.PREGNANT_CD&YEAR AS
	SELECT DISTINCT
		A.ID,
		CATS(A.ID_BIRTHDAY,'15') AS ID_BIRTHDAY, /*�N�ͤ�]��15��  ��ƫ��A��YYMMDD8.*/
		A.FUNC_DATE, 
		FLOOR(
			YRDIF(
				INPUT(CATS(A.ID_BIRTHDAY,'15'),YYMMDD8.),
				INPUT(A.FUNC_DATE,YYMMDD8.),
			'ACT/ACT')
		) AS AGE,
	A.ACODE_ICD9_1,
	A.ACODE_ICD9_2,
	A.ACODE_ICD9_3
	FROM NH.CD&YEAR  AS A
	WHERE 
		A.ACODE_ICD9_1 IN (SELECT ICD FROM NH_ICD.PREGNANT_ICD) OR
		A.ACODE_ICD9_2 IN (SELECT ICD FROM NH_ICD.PREGNANT_ICD) OR
		A.ACODE_ICD9_3 IN (SELECT ICD FROM NH_ICD.PREGNANT_ICD) 
	;
	QUIT;
%mend;

/*���]�X2007 ~2009���h���H��*/
%read_pregnant(2007);
%read_pregnant(2008);
%read_pregnant(2009);
%read_cd_pregnant(2007);
%read_cd_pregnant(2008);
%read_cd_pregnant(2009);

/*��X2007~2009 �~���H�ƨñư������ƪ�*/
/*
PROC SQL; 
CREATE TABLE NH.PREGNANT_UNION AS 
SELECT *
FROM NH.PREGNANT_DD2007
UNION 
SELECT*
FROM NH.PREGNANT_DD2008
UNION 
SELECT*
FROM NH.PREGNANT_DD2009
;
QUIT;
*/


/* �ư������~��**�n�ݲM��
PROC SQL;


CREATE TABLE NH.PREGNANT_UNION_ADULT AS
SELECT DISTINCT
	A.ID,
	CATS(A.ID_BIRTHDAY,'15') AS ID_BIRTHDAY, 
	A.IN_DATE, 
	A.AGE,
	A.ICD9CM_CODE,
	A.ICD9CM_CODE_1,
	A.ICD9CM_CODE_2,
	A.ICD9CM_CODE_3,
	A.ICD9CM_CODE_4    
FROM NH.PREGNANT_UNION AS A
WHERE 
	A.AGE >= 18
;
QUIT;	

*/
/*��07~09��ID ����2002~2006�Ҧ���case */
/*����06�~*/
/*
PROC SQL;
CREATE TABLE NH.PREGNANT2006 AS
SELECT DISTINCT
	A.ID,
	A.ICD9CM_CODE,
	A.ICD9CM_CODE_1,
	A.ICD9CM_CODE_2,
	A.ICD9CM_CODE_3,
	A.ICD9CM_CODE_4  
FROM NH.DD2006  AS A
WHERE   
	ID IN(SELECT ID FROM NH.PREGNANT_UNION_ADULT) AND(
	A.ICD
	)
;
QUIT;
*/
