from lxml import html
import requests, argparse, re, smtplib

parser = argparse.ArgumentParser()
parser.add_argument("-u","--username", help="OpenClinica username")
parser.add_argument("-p","--password", help="OpenClinica password")
args = parser.parse_args()

"""login step"""
login_url = 'http://localhost:8080/OpenClinica3141/j_spring_security_check'
login_action = {'action':'submit'}
login_payload = {
	'j_password':args.password,
	'j_username':args.username,
	'submit':"Login"
				}
s = requests.Session()
login = s.post(login_url,params=login_action,data=login_payload)

"""request and parse study audit logs to get subject_id list"""
audit_url = 'http://localhost:8080/OpenClinica3141/StudyAuditLog'
audit_params = 	{
	'maxRows':50
	,'studyAuditLogs_mr_':50
	,'studyAuditLogs_f_studySubject.status':'available'
				}
audit_subject_url = 'http://localhost:8080/OpenClinica3141/ViewStudySubjectAuditLog'

audit_request = s.get(audit_url,params=audit_params)
audit_response = html.fromstring(audit_request.text)
subjects = audit_response.xpath('//@href[contains(. ,"ViewStudySubjectAuditLog?id=")]')

class subject:
	'subject info scraped from OpenClinica'
	
	def __init__(self,id_database=None,id_manual=None,enrol_date=None,enrol_by=None):
		self.id_database = id_database
		self.id_manual = id_manual
		self.enrol_date = enrol_date
		self.enrol_by = enrol_by
		
	def as_row(self):
		print (
			"id_db", self.id_database 
			,"id_manual", self.id_manual 
			,"enrol_date", self.enrol_date
			,"enrol_by", self.enrol_by
			)

subject_list = []

for x in subjects:
	subject_id_db = re.search('id=([0-9]+)', x).group(1)

	"""go to each audit log page and get the enrol details"""
	audit_subject_request = s.get(audit_subject_url,params={'id':subject_id_db})
	audit_subject_response = html.fromstring(audit_subject_request.text)

	"""assign values to class instances, add them to a list"""
	subject_x = subject(
		 id_database=subject_id_db
		,id_manual=str(
			audit_subject_response.xpath(
				'substring-before(//h1/span/text()," Audit Logs")'
				).strip()
			)
		,enrol_date=str(
			audit_subject_response.xpath(
				'//tr/td[contains(.,"Subject created")]/following-sibling::td[1]/text()'
				)[0].strip()
			)
		,enrol_by=str(
			audit_subject_response.xpath(
				'//tr/td[contains(.,"Subject created")]/following-sibling::td[2]/text()'
				)[0].strip()
			)
		)
	subject_list.append(subject_x)

"""Now that we have our data, log out of OpenClinica"""
logout_url = http://localhost:8080/OpenClinica3141/j_spring_security_logout
logout = s.get(logout_url)

"""compose the message body using the list of subject instances"""
message = """
<html><head>
<style type="text/css">
body {font-family:Arial;font-size:11pt;}
table {border-collapse:collapse} 
table,th,td {border:1px solid black}
th,td {padding:5pt} 
th {font-weight:bold}
</style>
</head><body>
<p>Dear OpenClinica User,</p><p>This is summary of enrolled subjects.</p>
"""

"""add the table populated from scraping"""
message = message + "<table><th>Subject ID</th><th>Enrol Date</th><th>Enrol User</th>"
for x in subject_list:
	message = message + ("<tr>" + 
		"<td>" + x.id_manual + "</td>" +
		"<td>" + x.enrol_date + "</td>" +
		"<td>" + x.enrol_by + "</td>" +
		"</tr>"
		)
message = message + """</table>
<p>If you notice any errors 
<a href="mailto:yourSenderEmail@here?
Subject=Subject%20Update%20Email%20Problem">please let me know</a>
</p><p>Your pal,<br>The OpenClinica-bot</p></body></html>"""

"""send the message"""
gmail_user = 'yourSenderEmail@here'
gmail_pwd = 'yourPasswordHere'
session = smtplib.SMTP('smtp.gmail.com', 587)
session.ehlo()
session.starttls()
session.login(gmail_user, gmail_pwd)
email_subject = 'Study Subject Update'
body_of_email = message
recipient = 'yourRecipientEmail@here'
headers = "\r\n".join(["from: " + gmail_user,
			   "subject: " + email_subject,
			   "to: " + recipient,
			   "mime-version: 1.0",
			   "content-type: text/html"])
content = headers + "\r\n\r\n" + body_of_email
session.sendmail(gmail_user, recipient, content)