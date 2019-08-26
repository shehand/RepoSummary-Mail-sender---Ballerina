import ballerina/io;
import ballerina/http;
import ballerina/config;
import wso2/gmail;

gmail:GmailConfiguration gmailConfig = {
    clientConfig: {
        auth: {
            scheme: http:OAUTH2,
            config: {
                grantType: http:DIRECT_TOKEN,
                config: {
                    accessToken: config:getAsString("ACCESS_TOKEN"),
                    refreshConfig: {
                        refreshUrl: gmail:REFRESH_URL,
                        refreshToken: config:getAsString("REFRESH_TOKEN"),
                        clientId: config:getAsString("CLIENT_ID"),
                        clientSecret: config:getAsString("CLIENT_SECRET")
                    }
                }
            }
        }
    }
};


public function main(string... args) {

    var eml = io:readln("Enter email address : ");
    var emle = string.convert(eml);
    string email = emle;

    var un = io:readln("Enter email address : ");
    var unm = string.convert(un);
    string username = unm;

    gmail:Client gmailClient = new(gmailConfig);

    http:Client github = new("https://api.github.com/users/"+username);
    var response = github->get("/repos");

    if (response is http:Response) {
        var repoDetails = response.getJsonPayload();
        if (repoDetails is json) {
            int repoDetailsLength = repoDetails.length() - 1;
            string[] sendingRepoNames = [];
            string[] sendingRepoHtmlUrl = [];
            string[] sendingRepoLang = [];

            foreach var i in 0 ... repoDetailsLength {
                sendingRepoNames[i] = repoDetails[i].name.toString();
                sendingRepoHtmlUrl[i] = repoDetails[i].html_url.toString();
                sendingRepoLang[i] = repoDetails[i].language.toString();
            }

            string sendingMessage = "";

            foreach var i in 0 ... repoDetailsLength {
                sendingMessage += "Repository Name : " + sendingRepoNames[i] + " Repository URL : " + sendingRepoHtmlUrl[i] + " Repository Language : " + sendingRepoLang[i] + "\n";
            }

            gmail:MessageRequest messageRequest = {};
            messageRequest.recipient = email;
            messageRequest.sender = "shehane@wso2.com";
            messageRequest.subject = "Repository Summary";
            messageRequest.messageBody = sendingMessage;
            // Set the content type of the mail as TEXT_PLAIN or TEXT_HTML.
            messageRequest.contentType = gmail:TEXT_PLAIN;
            string userId = "me";
            // Send the message.
            var sendMessageResponse = gmailClient->sendMessage(userId, untaint messageRequest);
            if (sendMessageResponse is (string, string)) {
                // If successful, print the message ID and thread ID.
                (string, string) (messageId, threadId) = sendMessageResponse;
                io:println("Sent Message ID: " + messageId);
                io:println("Sent Thread ID: " + threadId);
            } else {
                // If unsuccessful, print the error returned.
                io:println("Error: ", sendMessageResponse);
            }


        } else {
            io:println(repoDetails.reason());
        }
    } else {
        io:println(response.reason());
    }
}
