Physicalexam_Igphysiungrouped <- data.frame(SubjectID=c(
'CAM101',
'CAM101',
'CAM103',
'CAM103',
'CAM103',
'CAM105',
'CAM105',
'CAM105',
'SCRC001',
'SCRC002',
'SCRC003',
'SCRC004',
'SCRC005',
'SCRC010',
'SCRC011',
'SMC101',
'SMC101',
'SMC102'),
ProtocolID=c(
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SMC',
'R01-123456 - R01-12345-SMC',
'R01-123456 - R01-12345-SMC'),
EventName=c(
'Registration Visit',
'Initial Treatment',
'Registration Visit',
'Initial Treatment',
'Follow-up Treatment',
'Registration Visit',
'Initial Treatment',
'Follow-up Treatment',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Initial Treatment',
'Registration Visit'),
EventStatus=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
EventStartDate=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
EventEndDate=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
EventLocation=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
SubjectAgeAtEvent=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
CRFName=c(
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English',
'Physical Exam - English'),
CRFStatus=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
CRFInterviewDate=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
CRFInterviewerName=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),		
StudyEventRepeatKey=c(
NA,
NA,
NA,
NA,
1,
NA,
NA,
1,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
ItemGroupRepeatKey=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
PEDAT=c(
as.Date("2011-07-01"),
as.Date("2011-07-01"),
as.Date("2011-07-06"),
as.Date("2011-07-13"),
as.Date("2011-07-27"),
as.Date("2011-06-01"),
as.Date("2011-06-01"),
as.Date("2011-06-02"),
as.Date("2011-06-21"),
as.Date("2011-07-01"),
as.Date("2011-07-01"),
as.Date("2011-06-21"),
as.Date("2011-06-21"),
as.Date("2011-06-01"),
as.Date("2011-06-12"),
as.Date("2011-07-06"),
as.Date("2011-06-01"),
as.Date("2011-07-01")),
PETIM=c(
'09:30',
'13:00',
'13:00',
NA,
'13:00',
'11:00',
'09:50',
'08:45',
'12:00',
'14:30',
NA,
'14:45',
NA,
'11:15',
'10:45',
'15:30',
'10:30',
'16:00'),
HEIGHT=c(
70,
78,
80,
78,
80,
69,
79,
80,
70,
56,
70,
78,
70,
100,
67,
86,
86,
80),
WEIGHT=c(
145,
160,
200,
190,
190,
170,
189,
195,
150,
120,
169,
170,
177,
190,
155,
195,
190,
178),
TEMPERATURE=c(
99,
98.9,
99,
99,
99,
99,
100.7,
101.0,
99,
99,
98,
97.9,
99,
100.3,
100.1,
99,
99.7,
99.9),
PULSE=c(
67,
70,
62,
62,
70,
62,
59,
60,
63,
66,
70,
66,
55,
72,
60,
60,
70,
61),
RESPIRATION=c(
17,
17,
16,
18,
18,
18,
16,
18,
15,
17,
16,
15,
15,
18,
17,
18,
18,
18),
SYSTOLIC=c(
'120',
'130',
'137',
'135',
'135',
'120',
'120',
'120',
'120',
'130',
'120',
'120',
'120',
'120',
'120',
'135',
'135',
'132'),
DIASTOLIC=c(
'80',
'80',
'84',
'84',
'84',
'80',
'80',
'75',
'80',
'89',
'80',
'80',
'80',
'80',
'80',
'80',
'84',
'82'),
BMI=c(
20.80,
18.49,
21.97,
21.95,
20.87,
25.10,
21.29,
21.42,
21.52,
26.90,
24.25,
19.64,
25.39,
13.36,
24.27,
18.54,
18.06,
19.55),
APPEARANCE=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
APPEARANCE_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
SKIN=c(
2,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
SKIN_COMMENTS=c(
'subject has signs of a rash on their forarms',
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
HEENT=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
HEENT_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
THYROID=c(
1,
1,
1,
1,
1,
2,
2,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
THYROID_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
'hypothyroidism',
'hypothyroidism',
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
CHEST=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
2,
1),
CHEST_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
'has congestion and deep cough',
NA),
LUNGS=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
LUNGS_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
BREAST=c(
1,
1,
99,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
BREASTS_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
HEART=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
HEART_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
ABDOMEN=c(
1,
1,
99,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
ABDOMEN_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
MUSCULOSKELETAL=c(
1,
1,
99,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
MUSCULOSKELETAL_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
GENITALIA=c(
1,
1,
99,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
GENITALIA_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
PELVIS=c(
1,
1,
99,
1,
1,
1,
1,
99,
1,
1,
1,
1,
1,
1,
1,
1,
1,
99),
PELVIS_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
RECTAL=c(
1,
1,
99,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
99),
RECTAL_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
PROSTATE=c(
1,
1,
99,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
PROSTATE_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
VASCULAR=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
VASCULAR_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
NEUROLOGICAL=c(
1,
1,
1,
1,
1,
1,
1,
99,
1,
1,
1,
1,
1,
1,
1,
1,
1,
99),
NEUROLOGICAL_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
LYMPHNODES=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
LYMPHNODES_COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA));

attributes(Physicalexam_Igphysiungrouped)$variable.labels <- c(
"Subject ID", "Site ID", "Event name", "Event status", "Event Startdate", "Event Enddate", "Event Location", "Subject age at event", "CRF Name", "CRF Status", "CRF Interviewdate", "CRF Interviewer name", "Event Repeat Index", "Itemgroup Repeat Index"
,"Date of Physical Exam"
,"Time of Physical Exam"
,"Height"
,"Weight"
,"Temperature"
,"Pulse Rate"
,"Respiration Rate"
,"Systolic"
,"Diastolic"
,"Body Mass Index"
,"Appearance"
,"Appearance Comments"
,"Skin"
,"Skin Comments"
,"H/E/E/N/T"
,"H/E/E/N/T Comments"
,"Thyroid"
,"Thyroid Comments"
,"Chest"
,"Chest Comments"
,"Lungs"
,"Lungs Comments"
,"Breasts"
,"Breasts Comments"
,"Heart"
,"Heart Comments"
,"Abdomen"
,"Abdomen Comments"
,"Musculoskeletal"
,"Musculoskeletal Comments"
,"Genitalia"
,"Genitalia Comments"
,"Pelvis"
,"Pelvis Comments"
,"Rectal"
,"Rectal Comments"
,"Prostate"
,"Prostate Comments"
,"Vascular"
,"Vascular Comments"
,"Neurological"
,"Neurological Comments"
,"Lymph Nodes"
,"Lymph Nodes Comments");

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.APPEARANCE<-factor(match(Physicalexam_Igphysiungrouped$APPEARANCE,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="APPEARANCE");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.APPEARANCE, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.SKIN<-factor(match(Physicalexam_Igphysiungrouped$SKIN,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="SKIN");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.SKIN, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.HEENT<-factor(match(Physicalexam_Igphysiungrouped$HEENT,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="HEENT");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.HEENT, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.THYROID<-factor(match(Physicalexam_Igphysiungrouped$THYROID,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="THYROID");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.THYROID, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.CHEST<-factor(match(Physicalexam_Igphysiungrouped$CHEST,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="CHEST");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.CHEST, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.LUNGS<-factor(match(Physicalexam_Igphysiungrouped$LUNGS,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="LUNGS");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.LUNGS, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.BREAST<-factor(match(Physicalexam_Igphysiungrouped$BREAST,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="BREAST");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.BREAST, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.HEART<-factor(match(Physicalexam_Igphysiungrouped$HEART,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="HEART");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.HEART, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.ABDOMEN<-factor(match(Physicalexam_Igphysiungrouped$ABDOMEN,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="ABDOMEN");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.ABDOMEN, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.MUSCULOSKELETAL<-factor(match(Physicalexam_Igphysiungrouped$MUSCULOSKELETAL,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="MUSCULOSKELETAL");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.MUSCULOSKELETAL, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.GENITALIA<-factor(match(Physicalexam_Igphysiungrouped$GENITALIA,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="GENITALIA");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.GENITALIA, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.PELVIS<-factor(match(Physicalexam_Igphysiungrouped$PELVIS,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="PELVIS");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.PELVIS, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.RECTAL<-factor(match(Physicalexam_Igphysiungrouped$RECTAL,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="RECTAL");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.RECTAL, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.PROSTATE<-factor(match(Physicalexam_Igphysiungrouped$PROSTATE,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="PROSTATE");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.PROSTATE, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.VASCULAR<-factor(match(Physicalexam_Igphysiungrouped$VASCULAR,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="VASCULAR");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.VASCULAR, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.NEUROLOGICAL<-factor(match(Physicalexam_Igphysiungrouped$NEUROLOGICAL,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="NEUROLOGICAL");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.NEUROLOGICAL, "label") <- "N_AB_NE"

codes <- c(
1,
4,
999);
levs <- c(
'Normal',
'Anormal',
'No examinado');
Physicalexam_Igphysiungrouped$f.LYMPHNODES<-factor(match(Physicalexam_Igphysiungrouped$LYMPHNODES,codes),levels=1:length(codes),labels=levs);
w<-which(names(Physicalexam_Igphysiungrouped)=="LYMPHNODES");
l<- dim(Physicalexam_Igphysiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Physicalexam_Igphysiungrouped<-Physicalexam_Igphysiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Physicalexam_Igphysiungrouped$f.LYMPHNODES, "label") <- "N_AB_NE"
Agentadministration_Igagentungrouped <- data.frame(SubjectID=c(
'CAM101',
'CAM101',
'CAM103',
'CAM105',
'SCRC001',
'SMC101'),
ProtocolID=c(
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SMC'),
EventName=c(
'Initial Treatment',
'Follow-up Treatment',
'Initial Treatment',
'Initial Treatment',
'Initial Treatment',
'Initial Treatment'),
EventStatus=c(
'',
'',
'',
'',
'',
''),
EventStartDate=c(
'',
'',
'',
'',
'',
''),
EventEndDate=c(
'',
'',
'',
'',
'',
''),
EventLocation=c(
'',
'',
'',
'',
'',
''),
SubjectAgeAtEvent=c(
'',
'',
'',
'',
'',
''),
CRFName=c(
'Agent Administration - v1.0',
'Agent Administration - v1.0',
'Agent Administration - v1.0',
'Agent Administration - v1.0',
'Agent Administration - v1.0',
'Agent Administration - v1.0'),
CRFStatus=c(
'',
'',
'',
'',
'',
''),
CRFInterviewDate=c(
'',
'',
'',
'',
'',
''),
CRFInterviewerName=c(
'',
'',
'',
'',
'',
''),		
StudyEventRepeatKey=c(
NA,
1,
NA,
NA,
NA,
NA),
ItemGroupRepeatKey=c(
NA,
NA,
NA,
NA,
NA,
NA),
PERIOD_SD=c(
as.Date("2011-07-06"),
as.Date("2013-07-12"),
as.Date("2011-07-06"),
as.Date("2011-06-02"),
as.Date("2011-06-13"),
as.Date("2011-07-06")),
PERIOD_ED=c(
NA,
as.Date("2013-07-08"),
as.Date("2011-07-06"),
NA,
NA,
as.Date("2011-07-06")),
MTD_DETERMINED=c(
0,
NA,
0,
1,
0,
1),
MTD_DAT=c(
NA,
NA,
NA,
as.Date("2011-07-06"),
NA,
as.Date("2011-07-06")),
MTD_DOSE=c(
NA,
NA,
NA,
100,
NA,
NA),
AGEN_INTERRUPTED=c(
0,
NA,
0,
0,
0,
1),
DAT_INTERRUPTED=c(
NA,
NA,
NA,
NA,
NA,
as.Date("2011-07-06")),
REASON_INTERRUPTED=c(
NA,
NA,
NA,
NA,
NA,
NA),
RESTARTED=c(
NA,
NA,
NA,
NA,
0,
0),
DAT_RESTARTED=c(
NA,
NA,
NA,
NA,
NA,
NA),
REASON_RESTARTED=c(
NA,
NA,
NA,
NA,
NA,
NA),
REG_MOD=c(
0,
NA,
0,
1,
1,
1),
DAT_MOD=c(
NA,
NA,
NA,
NA,
NA,
NA),
NEW_REG_DOSE=c(
NA,
NA,
NA,
NA,
NA,
NA),
NEW_REG_FREQ=c(
NA,
NA,
NA,
NA,
NA,
NA),
AMT_LAST_VIS=c(
120,
20,
50,
120,
1000,
120),
AMT_RET=c(
20,
20,
0,
20,
200,
20),
AMT_TAKEN=c(
40,
20,
40,
80,
700,
70),
AMT_MISS=c(
60.0000,
-20.0000,
10.0000,
20.0000,
100.0000,
30.0000),
COMPLIANCE=c(
-88,
NA,
1,
1,
1,
1),
NONCOMPLIANCE=c(
NA,
NA,
NA,
NA,
NA,
NA),
AGEN_PROVIDED=c(
-99,
NA,
1,
1,
1,
1),
AMT_PROVIDED=c(
NA,
NA,
50,
120,
NA,
80),
COMMENTS=c(
NA,
NA,
NA,
NA,
NA,
NA));

attributes(Agentadministration_Igagentungrouped)$variable.labels <- c(
"Subject ID", "Site ID", "Event name", "Event status", "Event Startdate", "Event Enddate", "Event Location", "Subject age at event", "CRF Name", "CRF Status", "CRF Interviewdate", "CRF Interviewer name", "Event Repeat Index", "Itemgroup Repeat Index"
,"Start of Agent Administration Period"
,"End of Agent Administration Period"
,"MTD Determined"
,"MTD Date"
,"MTD Dose"
,"Agent Interrupted"
,"Date Interrupted"
,"Reason Interrupted"
,"Restarted"
,"Date Restarted"
,"Reason Restarted"
,"Regimen Modified"
,"Date Modified"
,"New Regimen Dose"
,"New Regimen Frequency"
,"Amount Provided Last Visit"
,"Amount Returned This Visit"
,"Amount Taken This Period"
,"Amount Missing This Period"
,"Compliance"
,"Noncompliance Reason"
,"Agent Provided This Visit"
,"Amount Provided This Visit"
,"Comments");

codes <- c(
1,
0,
-99);
levs <- c(
'Yes',
'No',
'N/A');
Agentadministration_Igagentungrouped$f.MTD_DETERMINED<-factor(match(Agentadministration_Igagentungrouped$MTD_DETERMINED,codes),levels=1:length(codes),labels=levs);
w<-which(names(Agentadministration_Igagentungrouped)=="MTD_DETERMINED");
l<- dim(Agentadministration_Igagentungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Agentadministration_Igagentungrouped<-Agentadministration_Igagentungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Agentadministration_Igagentungrouped$f.MTD_DETERMINED, "label") <- "YNNA"

codes <- c(
1,
0,
-99);
levs <- c(
'Yes',
'No',
'N/A');
Agentadministration_Igagentungrouped$f.AGEN_INTERRUPTED<-factor(match(Agentadministration_Igagentungrouped$AGEN_INTERRUPTED,codes),levels=1:length(codes),labels=levs);
w<-which(names(Agentadministration_Igagentungrouped)=="AGEN_INTERRUPTED");
l<- dim(Agentadministration_Igagentungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Agentadministration_Igagentungrouped<-Agentadministration_Igagentungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Agentadministration_Igagentungrouped$f.AGEN_INTERRUPTED, "label") <- "YNNA"

codes <- c(
1,
0,
-99);
levs <- c(
'Yes',
'No',
'N/A');
Agentadministration_Igagentungrouped$f.RESTARTED<-factor(match(Agentadministration_Igagentungrouped$RESTARTED,codes),levels=1:length(codes),labels=levs);
w<-which(names(Agentadministration_Igagentungrouped)=="RESTARTED");
l<- dim(Agentadministration_Igagentungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Agentadministration_Igagentungrouped<-Agentadministration_Igagentungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Agentadministration_Igagentungrouped$f.RESTARTED, "label") <- "YNNA"

codes <- c(
1,
0,
-99);
levs <- c(
'Yes',
'No',
'N/A');
Agentadministration_Igagentungrouped$f.REG_MOD<-factor(match(Agentadministration_Igagentungrouped$REG_MOD,codes),levels=1:length(codes),labels=levs);
w<-which(names(Agentadministration_Igagentungrouped)=="REG_MOD");
l<- dim(Agentadministration_Igagentungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Agentadministration_Igagentungrouped<-Agentadministration_Igagentungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Agentadministration_Igagentungrouped$f.REG_MOD, "label") <- "YNNA"

codes <- c(
1,
0,
-99);
levs <- c(
'Yes',
'No',
'N/A');
Agentadministration_Igagentungrouped$f.AGEN_PROVIDED<-factor(match(Agentadministration_Igagentungrouped$AGEN_PROVIDED,codes),levels=1:length(codes),labels=levs);
w<-which(names(Agentadministration_Igagentungrouped)=="AGEN_PROVIDED");
l<- dim(Agentadministration_Igagentungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Agentadministration_Igagentungrouped<-Agentadministration_Igagentungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Agentadministration_Igagentungrouped$f.AGEN_PROVIDED, "label") <- "YNNA"

codes <- c(
1,
0,
-88);
levs <- c(
'Yes',
'No',
'Unknown');
Agentadministration_Igagentungrouped$f.COMPLIANCE<-factor(match(Agentadministration_Igagentungrouped$COMPLIANCE,codes),levels=1:length(codes),labels=levs);
w<-which(names(Agentadministration_Igagentungrouped)=="COMPLIANCE");
l<- dim(Agentadministration_Igagentungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Agentadministration_Igagentungrouped<-Agentadministration_Igagentungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Agentadministration_Igagentungrouped$f.COMPLIANCE, "label") <- "YNUNK"
Agentadministration_Dosetable <- data.frame(SubjectID=c(
'CAM101',
'CAM103',
'SCRC001',
'SMC101'),
ProtocolID=c(
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SMC'),
EventName=c(
'Initial Treatment',
'Initial Treatment',
'Initial Treatment',
'Initial Treatment'),
EventStatus=c(
'',
'',
'',
''),
EventStartDate=c(
'',
'',
'',
''),
EventEndDate=c(
'',
'',
'',
''),
EventLocation=c(
'',
'',
'',
''),
SubjectAgeAtEvent=c(
'',
'',
'',
''),
CRFName=c(
'Agent Administration - v1.0',
'Agent Administration - v1.0',
'Agent Administration - v1.0',
'Agent Administration - v1.0'),
CRFStatus=c(
'',
'',
'',
''),
CRFInterviewDate=c(
'',
'',
'',
''),
CRFInterviewerName=c(
'',
'',
'',
''),		
StudyEventRepeatKey=c(
NA,
NA,
NA,
NA),
ItemGroupRepeatKey=c(
1,
1,
1,
1),
DOSE_DAT=c(
as.Date("2011-07-06"),
as.Date("2011-07-06"),
as.Date("2011-06-07"),
as.Date("2011-07-06")),
DOSE_TIM=c(
NA,
NA,
NA,
NA),
AGEN_NAME=c(
NA,
'Docetaxel',
'Docetaxel',
NA),
AGEN_DOSE=c(
NA,
50,
10,
NA));

attributes(Agentadministration_Dosetable)$variable.labels <- c(
"Subject ID", "Site ID", "Event name", "Event status", "Event Startdate", "Event Enddate", "Event Location", "Subject age at event", "CRF Name", "CRF Status", "CRF Interviewdate", "CRF Interviewer name", "Event Repeat Index", "Itemgroup Repeat Index"
,"Dose Date"
,"Dose Time"
,"Agent Name"
,"Agent Dose");
Verificationofinformedconsent_Igverifungrouped <- data.frame(SubjectID=c(
'CAM101',
'CAM102',
'CAM103',
'CAM105',
'SCRC001',
'SCRC002',
'SCRC003',
'SCRC004',
'SCRC005',
'SCRC010',
'SCRC011',
'SMC101'),
ProtocolID=c(
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SMC'),
EventName=c(
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit'),
EventStatus=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
EventStartDate=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
EventEndDate=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
EventLocation=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
SubjectAgeAtEvent=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
CRFName=c(
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0',
'Verification of Informed Consent - v2.0'),
CRFStatus=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
CRFInterviewDate=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
CRFInterviewerName=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),		
StudyEventRepeatKey=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
ItemGroupRepeatKey=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
ELIGIBILITY_CONF=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
VERI_INIT=c(
'AG',
'AG',
'js',
'AG',
'ANG',
'ANG',
'AG',
'AG',
'MF',
'MF',
'MF',
'ANG'),
VERI_DATE=c(
as.Date("2011-07-06"),
as.Date("2011-07-06"),
as.Date("2011-07-06"),
as.Date("2011-06-01"),
as.Date("2011-06-01"),
as.Date("2011-06-22"),
as.Date("2011-06-20"),
as.Date("2011-06-01"),
as.Date("2011-06-01"),
as.Date("2011-05-31"),
as.Date("2011-06-12"),
as.Date("2011-07-06")),
IFC_PDF=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA));

attributes(Verificationofinformedconsent_Igverifungrouped)$variable.labels <- c(
"Subject ID", "Site ID", "Event name", "Event status", "Event Startdate", "Event Enddate", "Event Location", "Subject age at event", "CRF Name", "CRF Status", "CRF Interviewdate", "CRF Interviewer name", "Event Repeat Index", "Itemgroup Repeat Index"
,"Affirmation that a signed informed consent exists"
,"Verification Affirmation Initials"
,"Date"
,"PDF of consent");

codes <- c(
1,
0);
levs <- c(
'Yes',
'No');
Verificationofinformedconsent_Igverifungrouped$f.ELIGIBILITY_CONF<-factor(match(Verificationofinformedconsent_Igverifungrouped$ELIGIBILITY_CONF,codes),levels=1:length(codes),labels=levs);
w<-which(names(Verificationofinformedconsent_Igverifungrouped)=="ELIGIBILITY_CONF");
l<- dim(Verificationofinformedconsent_Igverifungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Verificationofinformedconsent_Igverifungrouped<-Verificationofinformedconsent_Igverifungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Verificationofinformedconsent_Igverifungrouped$f.ELIGIBILITY_CONF, "label") <- "YN"
Eligibility_Igeligiungrouped <- data.frame(SubjectID=c(
'CAM101',
'CAM103',
'CAM105',
'SCRC001',
'SCRC002',
'SCRC003',
'SCRC004',
'SCRC005',
'SCRC010',
'SCRC011',
'SMC101'),
ProtocolID=c(
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SCRC',
'R01-123456 - R01-12345-SMC'),
EventName=c(
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit',
'Registration Visit'),
EventStatus=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
EventStartDate=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
EventEndDate=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
EventLocation=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
SubjectAgeAtEvent=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
CRFName=c(
'Eligibility - v1.0',
'Eligibility - v1.0',
'Eligibility - v1.0',
'Eligibility - v1.0',
'Eligibility - v1.0',
'Eligibility - v1.0',
'Eligibility - v1.0',
'Eligibility - v1.0',
'Eligibility - v1.0',
'Eligibility - v1.0',
'Eligibility - v1.0'),
CRFStatus=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
CRFInterviewDate=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),
CRFInterviewerName=c(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
''),		
StudyEventRepeatKey=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
ItemGroupRepeatKey=c(
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA,
NA),
OVER_18=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
ECOG_STATUS=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
WBC_CT=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
PLATELET_CT=c(
1,
1,
1,
1,
1,
0,
1,
1,
1,
1,
1),
SERUM_CREATININE=c(
1,
1,
1,
1,
1,
0,
1,
1,
1,
1,
1),
SERUM_BILIRUBIN=c(
1,
1,
1,
1,
1,
0,
1,
1,
1,
1,
1),
CONTRACEPTION=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
INFORMED_CONSENT=c(
1,
1,
1,
1,
1,
1,
1,
1,
1,
1,
1),
INFORMED_CONSENT_DAT=c(
as.Date("2011-07-01"),
as.Date("2011-07-06"),
as.Date("2011-06-01"),
as.Date("2011-06-22"),
as.Date("2011-06-22"),
as.Date("2011-06-22"),
as.Date("2011-06-01"),
as.Date("2011-06-11"),
as.Date("2011-05-31"),
as.Date("2011-06-12"),
as.Date("2011-07-06")),
HIST_HEART_DISEASE=c(
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0),
CHEMOTHERAPY=c(
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0),
FASTING_CHOLESTEROL_TRIGLY=c(
0,
0,
0,
0,
0,
0,
0,
0,
NA,
0,
0),
NSAIDS=c(
0,
0,
0,
0,
0,
0,
0,
0,
1,
0,
0),
OTH_INVESTIGATIONAL_RX=c(
0,
0,
0,
0,
0,
0,
0,
0,
0,
0,
0));

attributes(Eligibility_Igeligiungrouped)$variable.labels <- c(
"Subject ID", "Site ID", "Event name", "Event status", "Event Startdate", "Event Enddate", "Event Location", "Subject age at event", "CRF Name", "CRF Status", "CRF Interviewdate", "CRF Interviewer name", "Event Repeat Index", "Itemgroup Repeat Index"
,"18 or older"
,"ECOG status of 0-2"
,"WBC count 3,500/L?"
,"platelet count"
,"serum creatinine"
,"serum bilirubin"
,"pregnancy/contraception"
,"informed consent"
,"date of informed consent"
,"history of heart disease"
,"chemo within the last 12 months"
,"fasting cholesterol or triglycerides"
,"currently taking NSAIDs on a regular basis"
,"investigational drug within last 4 months");

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.OVER_18<-factor(match(Eligibility_Igeligiungrouped$OVER_18,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="OVER_18");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.OVER_18, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.ECOG_STATUS<-factor(match(Eligibility_Igeligiungrouped$ECOG_STATUS,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="ECOG_STATUS");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.ECOG_STATUS, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.WBC_CT<-factor(match(Eligibility_Igeligiungrouped$WBC_CT,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="WBC_CT");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.WBC_CT, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.PLATELET_CT<-factor(match(Eligibility_Igeligiungrouped$PLATELET_CT,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="PLATELET_CT");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.PLATELET_CT, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.SERUM_CREATININE<-factor(match(Eligibility_Igeligiungrouped$SERUM_CREATININE,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="SERUM_CREATININE");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.SERUM_CREATININE, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.SERUM_BILIRUBIN<-factor(match(Eligibility_Igeligiungrouped$SERUM_BILIRUBIN,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="SERUM_BILIRUBIN");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.SERUM_BILIRUBIN, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.CONTRACEPTION<-factor(match(Eligibility_Igeligiungrouped$CONTRACEPTION,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="CONTRACEPTION");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.CONTRACEPTION, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.INFORMED_CONSENT<-factor(match(Eligibility_Igeligiungrouped$INFORMED_CONSENT,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="INFORMED_CONSENT");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.INFORMED_CONSENT, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.HIST_HEART_DISEASE<-factor(match(Eligibility_Igeligiungrouped$HIST_HEART_DISEASE,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="HIST_HEART_DISEASE");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.HIST_HEART_DISEASE, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.CHEMOTHERAPY<-factor(match(Eligibility_Igeligiungrouped$CHEMOTHERAPY,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="CHEMOTHERAPY");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.CHEMOTHERAPY, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.FASTING_CHOLESTEROL_TRIGLY<-factor(match(Eligibility_Igeligiungrouped$FASTING_CHOLESTEROL_TRIGLY,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="FASTING_CHOLESTEROL_TRIGLY");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.FASTING_CHOLESTEROL_TRIGLY, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.NSAIDS<-factor(match(Eligibility_Igeligiungrouped$NSAIDS,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="NSAIDS");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.NSAIDS, "label") <- "y,n"

codes <- c(
1,
0);
levs <- c(
'YES',
'NO');
Eligibility_Igeligiungrouped$f.OTH_INVESTIGATIONAL_RX<-factor(match(Eligibility_Igeligiungrouped$OTH_INVESTIGATIONAL_RX,codes),levels=1:length(codes),labels=levs);
w<-which(names(Eligibility_Igeligiungrouped)=="OTH_INVESTIGATIONAL_RX");
l<- dim(Eligibility_Igeligiungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Eligibility_Igeligiungrouped<-Eligibility_Igeligiungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Eligibility_Igeligiungrouped$f.OTH_INVESTIGATIONAL_RX, "label") <- "y,n"
Adverseevents_Igadverungrouped <- data.frame(SubjectID=c(
'SMC101'),
ProtocolID=c(
'R01-123456 - R01-12345-SMC'),
EventName=c(
'Adverse Events'),
EventStatus=c(
''),
EventStartDate=c(
''),
EventEndDate=c(
''),
EventLocation=c(
''),
SubjectAgeAtEvent=c(
''),
CRFName=c(
'Adverse Events - v1.0'),
CRFStatus=c(
''),
CRFInterviewDate=c(
''),
CRFInterviewerName=c(
''),		
StudyEventRepeatKey=c(
NA),
ItemGroupRepeatKey=c(
NA),
1_AEYN=c(
1),
1_AETERM=c(
NA),
1_AESTDTC=c(
NA),
1_AEENDTC=c(
NA),
1_AESEV=c(
NA),
1_AESER=c(
NA),
1_AEREL=c(
NA),
1_AEACN=c(
NA),
1_AEOUT=c(
NA),
2_AEYN=c(
NA));

attributes(Adverseevents_Igadverungrouped)$variable.labels <- c(
"Subject ID", "Site ID", "Event name", "Event status", "Event Startdate", "Event Enddate", "Event Location", "Subject age at event", "CRF Name", "CRF Status", "CRF Interviewdate", "CRF Interviewer name", "Event Repeat Index", "Itemgroup Repeat Index"
,"Adverse Event Experienced"
,"Adverse Event"
,"Start Date"
,"Stop Date"
,"Severity"
,"Serious AE"
,"Relationship"
,"Action Taken"
,"Outcome"
,"Adverse Event Experienced");

codes <- c(
1,
0);
levs <- c(
'Yes',
'No');
Adverseevents_Igadverungrouped$f.1_AEYN<-factor(match(Adverseevents_Igadverungrouped$1_AEYN,codes),levels=1:length(codes),labels=levs);
w<-which(names(Adverseevents_Igadverungrouped)=="1_AEYN");
l<- dim(Adverseevents_Igadverungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Adverseevents_Igadverungrouped<-Adverseevents_Igadverungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Adverseevents_Igadverungrouped$f.1_AEYN, "label") <- "Y,N"

codes <- c(
1,
0);
levs <- c(
'Yes',
'No');
Adverseevents_Igadverungrouped$f.1_AESER<-factor(match(Adverseevents_Igadverungrouped$1_AESER,codes),levels=1:length(codes),labels=levs);
w<-which(names(Adverseevents_Igadverungrouped)=="1_AESER");
l<- dim(Adverseevents_Igadverungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Adverseevents_Igadverungrouped<-Adverseevents_Igadverungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Adverseevents_Igadverungrouped$f.1_AESER, "label") <- "Y,N"

codes <- c(
1,
0);
levs <- c(
'Yes',
'No');
Adverseevents_Igadverungrouped$f.2_AEYN<-factor(match(Adverseevents_Igadverungrouped$2_AEYN,codes),levels=1:length(codes),labels=levs);
w<-which(names(Adverseevents_Igadverungrouped)=="2_AEYN");
l<- dim(Adverseevents_Igadverungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Adverseevents_Igadverungrouped<-Adverseevents_Igadverungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Adverseevents_Igadverungrouped$f.2_AEYN, "label") <- "Y,N"

codes <- c(
1,
2,
3);
levs <- c(
'Mild',
'Moderate',
'Severe');
Adverseevents_Igadverungrouped$f.1_AESEV<-factor(match(Adverseevents_Igadverungrouped$1_AESEV,codes),levels=1:length(codes),labels=levs);
w<-which(names(Adverseevents_Igadverungrouped)=="1_AESEV");
l<- dim(Adverseevents_Igadverungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Adverseevents_Igadverungrouped<-Adverseevents_Igadverungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Adverseevents_Igadverungrouped$f.1_AESEV, "label") <- "severity"

codes <- c(
0,
1,
2,
3);
levs <- c(
'Not Related',
'Unlikely Related',
'Possibly Related',
'Related');
Adverseevents_Igadverungrouped$f.1_AEREL<-factor(match(Adverseevents_Igadverungrouped$1_AEREL,codes),levels=1:length(codes),labels=levs);
w<-which(names(Adverseevents_Igadverungrouped)=="1_AEREL");
l<- dim(Adverseevents_Igadverungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Adverseevents_Igadverungrouped<-Adverseevents_Igadverungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Adverseevents_Igadverungrouped$f.1_AEREL, "label") <- "relationship"

codes <- c(
0,
1,
2,
3,
4,
5,
6);
levs <- c(
'Dose Increased',
'Dose Not Changed',
'Dose Reduced',
'Drug Interrupted',
'Drug Withdrawn',
'Not Applicable',
'Unknown');
Adverseevents_Igadverungrouped$f.1_AEACN<-factor(match(Adverseevents_Igadverungrouped$1_AEACN,codes),levels=1:length(codes),labels=levs);
w<-which(names(Adverseevents_Igadverungrouped)=="1_AEACN");
l<- dim(Adverseevents_Igadverungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Adverseevents_Igadverungrouped<-Adverseevents_Igadverungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Adverseevents_Igadverungrouped$f.1_AEACN, "label") <- "action taken"

codes <- c(
1,
2,
3,
4);
levs <- c(
'Recovered',
'Still under treatment/observation',
'Alive with sequelae',
'Died');
Adverseevents_Igadverungrouped$f.1_AEOUT<-factor(match(Adverseevents_Igadverungrouped$1_AEOUT,codes),levels=1:length(codes),labels=levs);
w<-which(names(Adverseevents_Igadverungrouped)=="1_AEOUT");
l<- dim(Adverseevents_Igadverungrouped)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Adverseevents_Igadverungrouped<-Adverseevents_Igadverungrouped[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Adverseevents_Igadverungrouped$f.1_AEOUT, "label") <- "outcome"
Concomitantmedications_Concomitantmedications <- data.frame(SubjectID=c(
'CAM101',
'CAM101',
'CAM105',
'SMC101'),
ProtocolID=c(
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-123456-CCSO',
'R01-123456 - R01-12345-SMC'),
EventName=c(
'Initial Treatment',
'Initial Treatment',
'Initial Treatment',
'Initial Treatment'),
EventStatus=c(
'',
'',
'',
''),
EventStartDate=c(
'',
'',
'',
''),
EventEndDate=c(
'',
'',
'',
''),
EventLocation=c(
'',
'',
'',
''),
SubjectAgeAtEvent=c(
'',
'',
'',
''),
CRFName=c(
'Concomitant Medications - v1.0',
'Concomitant Medications - v1.0',
'Concomitant Medications - v1.0',
'Concomitant Medications - v1.0'),
CRFStatus=c(
'',
'',
'',
''),
CRFInterviewDate=c(
'',
'',
'',
''),
CRFInterviewerName=c(
'',
'',
'',
''),		
StudyEventRepeatKey=c(
NA,
NA,
NA,
NA),
ItemGroupRepeatKey=c(
1,
2,
1,
1),
Con_Med_Name=c(
'asprin',
'cialis',
'synthroid',
'asprin'),
Con_Med_Start=c(
as.Date("2011-06-01"),
as.Date("2011-05-16"),
as.Date("2009-05-06"),
as.Date("2011-07-05")),
Con_Med_End=c(
NA,
NA,
NA,
as.Date("2011-07-06")),
Con_Med_Cont=c(
1,
1,
1,
0),
Con_Med_form=c(
'200',
'50',
'40',
'200'));

attributes(Concomitantmedications_Concomitantmedications)$variable.labels <- c(
"Subject ID", "Site ID", "Event name", "Event status", "Event Startdate", "Event Enddate", "Event Location", "Subject age at event", "CRF Name", "CRF Status", "CRF Interviewdate", "CRF Interviewer name", "Event Repeat Index", "Itemgroup Repeat Index"
,"Medication name"
,"Start date"
,"End date"
,"Ongoing/Continuing"
,"Dose");

codes <- c(
1,
0);
levs <- c(
'yes',
'no');
Concomitantmedications_Concomitantmedications$f.Con_Med_Cont<-factor(match(Concomitantmedications_Concomitantmedications$Con_Med_Cont,codes),levels=1:length(codes),labels=levs);
w<-which(names(Concomitantmedications_Concomitantmedications)=="Con_Med_Cont");
l<- dim(Concomitantmedications_Concomitantmedications)[2];
if (!is.null(w) & !is.null(l)){} else{if(w<(l-1))Concomitantmedications_Concomitantmedications<-Concomitantmedications_Concomitantmedications[,c(1:w,l,(1+w):(l-1))]};
rm(l,w);
attr(Concomitantmedications_Concomitantmedications$f.Con_Med_Cont, "label") <- "y,n"
