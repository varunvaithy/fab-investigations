## Introduction FAB Grid Kusto Auth Cert Renewal

|                |        				                |
| :--------------|-------------------------------------:|
| Service Area   | SPO  			   					|
| Component      | Fraud And Abuse Grid					|
| Owning Team    | SharePoint SNAP\FraudAbuseRemediation|

### Purpose
This TSG is intended to document the cert renewal process for Fraud and Abuse Kusto Auth Cert(FABGridKustoAuth).

### Background
#### Cert Types
| Cert Type          | Purpose       																		 |
| :----------------  |--------------------------------------------------------------------------------------:|
| FABGridKustoAuth   | Used by Fraud and Abuse grid jobs framework to authenticate with Kusto for ingestion. |
| 					 | These certs are farm scoped & active in all public SPO Environments.					 | 

	
### Resource info
| Resource           	| Value       											 |
|:----------------------|-------------------------------------------------------:|
| ServiceTree ID	 	| cc0eebdd-ca39-47ce-a8ab-266de31d415b (Fraud and Abuse) |
| Subscription ID	 	| c93de875-daea-46c8-a4ee-4085e10776a6					 | 
| Azure tenant ID Public| cdc5aeea-15c5-4db6-b079-fcadd2505dc2				 	 | 
| Torus team	Public  | ODSPFAB												 | 
| Resource              | Kusto Cluster					 						 | 

#### Log/QoS data
If there is a regression observed in this chart for Kusto Ingestion Failures, Certificate could be one of the reasons. [Kusto Ingestion Failures]

#### Design doc
[FAB_E2E_Design_V0.1.docx](https://microsoftapc.sharepoint.com/:w:/t/ODSP_IDC_ACE2/ERz99MKH_bxLpc1iobwCtbMBdg-0r2_un-4kH19GveMkEg?e=jdh35n&ovuser=72f988bf-86f1-41af-91ab-2d7cd011db47%2Cswetaprakash%40microsoft.com&wdOrigin=TEAMS-ELECTRON.p2p.bim&wdExp=TEAMS-TREATMENT&wdhostclicktime=1677753094459&web=1&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiIyNy8yMzAyMjYwMTgwMSIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D)

#### Emergency renewal/rotation
These certificates should be automatically renewed - a new certificate should automatically be created upon the creation of an IcM ticket notifying upcoming certificate expiration. If it failed to create a new one or if the certificate should be renewed earlier, you can file a request for a new certificate manually:

```
$certType = FABGridKustoAuth
$existingCert = Get-GridCertificate -Type $certType -State Active | Sort-Object -Property Version -Descending | Select-Object -First 1
$subjectName = (Get-GridCertificateMetadata -CertType $certType).FriendlyName
Request-GridClmCertificate -SubjectName $subjectName -TeamAlias odspfab -SPOCertificateType $certType -Scope Global -ObjectID 0 -BusinessReason "FABGridKustoAuth Kusto Auth Cert Renewal" -ExistingCertificateThumbprint $existingCert.Thumbprint -ExistingCertificateExpirationDate $existingCert.ExpirationDate
```
**You can check if the certificate has been created or what the status of the request is:**

```
$certType = FABGridKustoAuth 
$subjectName = (Get-GridCertificateMetadata -CertType $certType).FriendlyName

#to see if new cert has been created:**
Get-GridCertificateMetaData -FriendlyName $subjectName -CreatedDateLowerBound ([datetime]::Now.AddMonths(-1)) -State Active

#if no new cert, see the progress on the cert request:
$existingCert = Get-GridCertificate -Type $certType -State Active | Sort-Object -Property Version -Descending | Select-Object -First 1
Get-GridClmCertificateRequest -ExistingCertificateThumbprint $existingCert.Thumbprint
```

**Please also refer to the cert team's documentation on [Renewal](https://onedrive.visualstudio.com/SharePoint%20Online/_wiki/wikis/SharePoint-Online.wiki/17006/Renewal) and [checking cert deployment status](https://onedrive.visualstudio.com/SharePoint%20Online/_wiki/wikis/SharePoint-Online.wiki/17011/*Check-certificate-deployment-status).**