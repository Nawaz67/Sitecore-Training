<%@ Page Language="C#" %>

<%@ Import Namespace="System" %>
<%@ Import Namespace="Sitecore.Analytics" %>
<%@ Import Namespace="Microsoft.Extensions.DependencyInjection" %>
<%@ Import Namespace="Sitecore.Analytics.Tracking" %>
<%@ Import Namespace="Sitecore.XConnect" %>
<%@ Import Namespace="Sitecore.XConnect.Client" %>
<%@ Import Namespace="Sitecore.XConnect.Client.Configuration" %>
<%@ Import Namespace="Sitecore.XConnect.Collection.Model" %>
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Web" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>

    <script runat="server">

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtEmail.Text.Trim()))
            {
                return;
            }
            
            string firstName = txtFirstName.Text;
            string lastName = txtLastName.Text;
            string jobTitle = txtJobTitle.Text;
            string email = txtEmail.Text;
        
           string contactId = TrackNewContact(firstName, lastName, email, jobTitle );


            txtEmail.Text = "";
            txtFirstName.Text = "";
            txtLastName.Text = "";
            txtJobTitle.Text = "";

            Session.Abandon();
            lblMessage.Text = contactId + " Contact Created";
        }

                public string TrackNewContact(string firstName, string lastName, string emailAddress, string jobTitle)
        {
            string contactGuid = string.Empty;
            using (var client = SitecoreXConnectClientConfiguration.GetClient())
            {
                try
                {
                    if (Tracker.Current == null && Tracker.Enabled)
                    {
                        Tracker.StartTracking();
                    }

                    ITracker CurrentTracker = Tracker.Current;

                    var emailIdent = new IdentifiedContactReference("IdentifiedEmail", emailAddress);

                    //Identify with Email
                    //Old Way
                    //CurrentTracker.Session.IdentifyAs(emailIdent.Source, emailIdent.Identifier);

                    //New Way
                    var identificationManager = Sitecore.DependencyInjection.ServiceLocator.ServiceProvider.GetRequiredService<Sitecore.Analytics.Tracking.Identification.IContactIdentificationManager>();
                    Sitecore.Analytics.Tracking.Identification.IdentificationResult result = identificationManager.IdentifyAs(new Sitecore.Analytics.Tracking.Identification.KnownContactIdentifier(emailIdent.Source, emailIdent.Identifier));

                    var expandOptions = new ContactExpandOptions(
                        CollectionModel.FacetKeys.PersonalInformation,
                        CollectionModel.FacetKeys.EmailAddressList);

                    var executionOptions = new ContactExecutionOptions(expandOptions);

                    //Old Way
                    //var contact = client.Get(emailIdent, expandOptions);

                    //New Way
                    var contact = client.Get(emailIdent, executionOptions);
                    contactGuid = contact.Id.HasValue ? contact.Id.Value.ToString() : string.Empty;

                    //Set Fields
                    SetPersonalInformation(firstName, lastName, contact, client, jobTitle);
                    SetEmail(emailAddress, contact, client);

                    client.Submit();

                    if (Tracker.Current != null)
                    {
                        Tracker.Current.EndVisit(true);
                    }

                }
                catch (Exception ex)
                {

                }
            }
            return contactGuid;
        }

        public void SetPersonalInformation(string firstName, string lastName, Sitecore.XConnect.Contact contact,
   IXdbContext client, string jobTitle)
        {
            if (string.IsNullOrEmpty(firstName) && string.IsNullOrEmpty(lastName))
                return;
            var personalInfoFacet = contact.Personal() ?? new PersonalInformation();
            //Set persona value
            personalInfoFacet.JobTitle = jobTitle;
            client.SetPersonal(contact, personalInfoFacet);

            if (personalInfoFacet.FirstName == firstName && personalInfoFacet.LastName == lastName)
                return;
            personalInfoFacet.FirstName = firstName;
            personalInfoFacet.LastName = lastName;

            client.SetPersonal(contact, personalInfoFacet);
        }

        public void SetEmail(string email, Sitecore.XConnect.Contact contact, IXdbContext client)
        {
            if (string.IsNullOrEmpty(email))
                return;
            var emailFacet = contact.Emails();
            if (emailFacet == null)
            {
                emailFacet = new EmailAddressList(new EmailAddress(email, false), "Preferred");
            }
            else
            {
                if (emailFacet.PreferredEmail.SmtpAddress == email)
                    return;
                emailFacet.PreferredEmail = new EmailAddress(email, false);
            }
            client.SetEmails(contact, emailFacet);
        }

    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            Email :
            <asp:TextBox ID="txtEmail" runat="server"></asp:TextBox>
            <br />
            First Name :
            <asp:TextBox ID="txtFirstName" runat="server"></asp:TextBox>
            <br />
            Last Name :
            <asp:TextBox ID="txtLastName" runat="server"></asp:TextBox>
            <br />
            Job Title :
            <asp:TextBox ID="txtJobTitle" runat="server"></asp:TextBox>
            <br />
          <!--  Photo:
            <asp:FileUpload ID="fluPhoto" runat="server" />
            <br /> -->

            <asp:Button ID="btnSubmit" runat="server" Text="Submit" OnClick="btnSubmit_Click" />
            <br />
            <asp:Label ID="lblMessage" runat="server" Text=""></asp:Label>
        </div>
    </form>
</body>
</html>
