<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template name="get_tablename">
<xsl:param name="formname" />
<xsl:param name="groupname" />
<xsl:param name="groupid" />
<xsl:choose>
<xsl:when test="($formname='FPM Administered Activity') and (contains($groupname,'_UNGROUPED'))">AdministeredActivity</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Blood and lymphatic system disorders')">AELogBlood</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Cardiac disorders')">AELogCardiac</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Congenital, familial and genetic disorders')">AELogCongenital</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Ear and labyrinth disorders')">AELogEar</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Endocrine disorders')">AELogEndocrine</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Eye disorders')">AELogEye</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Gastrointestinal disorders')">AELogGastrointestinal</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'General disorders and administration site conditions')">AELogGeneral</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Hepatobiliary disorders')">AELogHepatobiliary</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Immune system disorders')">AELogImmune</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Infections and infestations')">AELogInfections</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Injury, poisoning and procedural complications')">AELogInjury</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Investigations')">AELogInvestigations</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Metabolism and nutrition disorders')">AELogMetabolism</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Musculoskeletal and connective tissue disorders')">AELogMusculoskeletal</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Neoplasms benign, malignant and unspecified (incl cysts and polyps)')">AELogNeoplasms</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Nervous system disorders')">AELogNervous</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Pregnancy, puerperium and perinatal conditions')">AELogPregnancy</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Psychiatric disorders')">AELogPsychiatric</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Renal and urinary disorders')">AELogRenal</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Reproductive system and breast disorders')">AELogReproductive</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Respiratory, thoracic and mediastinal disorders')">AELogRespiratory</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Skin and subcutaneous tissue disorders')">AELogSkin</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Social circumstances')">AELogSocial</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Surgical and medical procedures')">AELogSurgical</xsl:when>
<xsl:when test="($formname='FPM AE Log') and ($groupname = 'Vascular disorders')">AELogVascular</xsl:when>
<xsl:when test="($formname='FPM Baseline Abnormalities') and (contains($groupname,'_UNGROUPED'))">BaselineAbnormalitiesAssessment</xsl:when>
<xsl:when test="($formname='FPM Baseline Abnormalities') and ($groupname = 'Baseline Abnormalities')">BaselineAbnormalities</xsl:when>
<xsl:when test="($formname='FPM Biochemistry') and (contains($groupname,'_UNGROUPED'))">Biochemistry</xsl:when>
<xsl:when test="($formname='FPM Biodistribution') and (contains($groupname,'_UNGROUPED'))">Biodistribution</xsl:when>
<xsl:when test="($formname='FPM Blinded Scan Review') and (contains($groupname,'_UNGROUPED'))">BlindedScanReview</xsl:when>
<xsl:when test="($formname='FPM Blinded Scan Review') and ($groupname = 'Activity Exceeding Normal Physiology')">BlindedScanReviewExceedingPhysiology</xsl:when>
<xsl:when test="($formname='FPM Blinded Scan Review Consensus Lesions') and ($groupname = 'Activity Exceeding Normal Physiology')">BlindedScanReviewConsensusLesions</xsl:when>
<xsl:when test="($formname='FPM Clotting') and (contains($groupname,'_UNGROUPED'))">Clotting</xsl:when>
<xsl:when test="($formname='FPM Concomitant Medications') and (contains($groupname,'_UNGROUPED'))">ConcomitantMedications</xsl:when>
<xsl:when test="($formname='FPM Concomitant Medications') and ($groupname = 'Concomitant Medications_table')">ConcomitantMedicationsLog</xsl:when>
<xsl:when test="($formname='FPM Death') and (contains($groupname,'_UNGROUPED'))">Death</xsl:when>
<xsl:when test="($formname='FPM Disease-specific Medical History') and (contains($groupname,'_UNGROUPED'))">DiseaseSpecificMedicalHistory</xsl:when>
<xsl:when test="($formname='FPM Dosimetry') and (contains($groupname,'_UNGROUPED'))">Dosimetry</xsl:when>
<xsl:when test="($formname='FPM Excreted Activity in Urine') and (contains($groupname,'_UNGROUPED'))">ExcretedActivityInUrine</xsl:when>
<xsl:when test="($formname='FPM Further Treatment') and (contains($groupname,'_UNGROUPED'))">FurtherTreatment</xsl:when>
<xsl:when test="($formname='FPM Further Treatment') and ($groupname = 'Further_Treatment_biotherapy')">FurtherTreatmentBiotherapy</xsl:when>
<xsl:when test="($formname='FPM Further Treatment') and ($groupname = 'Further_Treatment_chemotherapy')">FurtherTreatmentChemotherapy</xsl:when>
<xsl:when test="($formname='FPM Further Treatment') and ($groupname = 'Further_Treatment_immunotherapy')">FurtherTreatmentImmunotherapy</xsl:when>
<xsl:when test="($formname='FPM Further Treatment') and ($groupname = 'Further_Treatment_other')">FurtherTreatmentOther</xsl:when>
<xsl:when test="($formname='FPM Further Treatment') and ($groupname = 'Further_Treatment_radiotherapy')">FurtherTreatmentRadiotherapy</xsl:when>
<xsl:when test="($formname='FPM Further Treatment') and ($groupname = 'Further_Treatment_surgery')">FurtherTreatmentSurgery</xsl:when>
<xsl:when test="($formname='FPM Haematology') and (contains($groupname,'_UNGROUPED'))">Haematology</xsl:when>
<xsl:when test="($formname='FPM Medical History') and (contains($groupname,'_UNGROUPED'))">MedicalHistory</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Cardiovascular')">MedicalHistoryCardiovascular</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Ear, Nose and Throat')">MedicalHistoryEar</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Endocrine')">MedicalHistoryEndocrine</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Eyes')">MedicalHistoryEyes</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Gastrointestinal')">MedicalHistoryGastrointestinal</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Haematological/lymphatic')">MedicalHistoryHaematological</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Hair')">MedicalHistoryHair</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Hepatic')">MedicalHistoryHepatic</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Musculoskeletal')">MedicalHistoryMusculoskeletal</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Neurological')">MedicalHistoryNeurological</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Other')">MedicalHistoryOther</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Previous adverse/allergic drug reaction')">MedicalHistoryPreviousReaction</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Psychiatric')">MedicalHistoryPsychiatric</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Renal')">MedicalHistoryRenal</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Respiratory')">MedicalHistoryRespiratory</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Skin')">MedicalHistorySkin</xsl:when>
<xsl:when test="($formname='FPM Medical History') and ($groupname = 'Urogenital')">MedicalHistoryUrogenital</xsl:when>
<xsl:when test="($formname='FPM Metabolism of FPM') and (contains($groupname,'_UNGROUPED'))">MetabolismOfFPM</xsl:when>
<xsl:when test="($formname='FPM Physical Exam') and (contains($groupname,'_UNGROUPED'))">PhysicalExam</xsl:when>
<xsl:when test="($formname='FPM Pregnancy Test') and (contains($groupname,'_UNGROUPED'))">PregnancyTest</xsl:when>
<xsl:when test="($formname='FPM Secondary Endpoint Information') and ($groupname = 'Background')">SecondaryEndpointBackground</xsl:when>
<xsl:when test="($formname='FPM Secondary Endpoint Information') and ($groupname = 'Malignant')">SecondaryEndpointMalignant</xsl:when>
<xsl:when test="($formname='FPM Secondary Endpoint Information') and ($groupname = 'NonMalignant')">SecondaryEndpointNonMalignant</xsl:when>
<xsl:when test="($formname='FPM Temp, BP and Pulse in Follow-up') and (contains($groupname,'_UNGROUPED'))">TempBPPulseFollowUp</xsl:when>
<xsl:when test="($formname='FPM Temp, BP, Pulse, PKRMA, SaO2 and Scans on Day of 18F FPM Injection') and (contains($groupname,'_UNGROUPED'))">TempBPPulsePKRMASaO2Scans</xsl:when>
<xsl:when test="($formname='FPM: Non-tumour Imaging Abnormalities') and ($groupname = 'sites of imaging abnormality without proven disease')">NonTumourImagingAbnormalities</xsl:when>
<xsl:when test="($formname='FPM: Non-validated Imaging Abnormalities') and ($groupname = 'Non-validated Imaging Abnormalities')">NonValidatedImagingAbnormalities</xsl:when>
<xsl:when test="($formname='FPM: Scan Result Validation') and ($groupname = 'Sites of proven disease')">ScanResultValidationProvenDisease</xsl:when>
<xsl:when test="($formname='FPM: Scan Result Validation') and ($groupname = 'Sites of proven melanoma')">ScanResultValidationProvenMelanoma</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$groupid" />
</xsl:otherwise>
</xsl:choose>
</xsl:template>
<xsl:template name="get_studyname">FPM</xsl:template>
</xsl:stylesheet>