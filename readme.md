#  🚃 PTV Stops 🚝
Made for a work Hack Day project.

Returns the next 3 trams headed into the city from our two closes tram stops (so we know when to leave work)

## How to Use

- Create an AWS Lambda Function with an API Gateway in front of it.
- In Amazon's IDE, create a new file called `ptv_stop.rb`.
-- Pase the content of `ptv_stop.rb` and `index.rb` into the Amazon files.
- Paste your PTV API Developer ID and Secret Key into the Lambda Environment variable fields under `DEVID` and `KEY` (you can find info on requesting a key from PTV [here](https://static.ptv.vic.gov.au/PTV/PTV%20docs/API/1475462320/PTV-Timetable-API-key-and-signature-document.RTF) (RTF document))
- Setup your Slack to point to the URL of your new Lambda function
- Profit!

## Want to change it?

This project could pretty easily be modified / extended to accommodate other stops.
You can get stop information, direction information and route information by inspecting
the [PTV Journey Planner](https://www.ptv.vic.gov.au/route/services/1041/96/#) and checking out the network calls,
or just use the API.

## Todo
- Automatic deployments to Lambda
- Tests 😳
