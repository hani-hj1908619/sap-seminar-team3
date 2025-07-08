const cds = require("@sap/cds");

class VRPAnalyticsService extends cds.ApplicationService {
  init() {
    this.on("summary", (req) => this.getAISummary(req));
    return super.init();
  }

  async getAISummary(req) {
    let solutions = await SELECT().from(
      this.entities.SolutionPerformanceAnalytics
    );
    const headers = Object.keys(solutions[0]);
    let csv = headers.join(",") + "\n";

    solutions.forEach((obj) => {
      const values = headers.map((header) => obj[header]);
      csv += values.join(",") + "\n";
    });

    const body = {
      messages: [
        {
          role: "system",
          content: `
### System
You are an expert data analyst tasked with interpreting and summarizing performance data from vehicle routing problem (VRP) solutions. Your goal is to derive meaningful insights from the provided dataset and explain the quality and characteristics of effective VRP solutions.

### Instructions
- Summarize the typical performance metrics (e.g., average cost, vehicle count, distance, compliance percentage).
- Identify patterns or characteristics of efficient solutions (e.g., high utilization, low cost, high compliance).
- Differentiate performance across various VRP scenarios if possible (e.g., large vs small customer count, high vs low vehicle usage).
- Visualize insights where appropriate (e.g., distribution of compliance %, cost vs utilization, etc.).
- Present actionable observations about what makes a VRP solution effective.

Finally, provide a concise summary of the overall performance of the VRP solutions based on the provided data.

### Context
The CSV data provided consists of multiple records, each representing a VRP solution with metrics such as total cost, customer count, distance, vehicle utilization, time window compliance, and delivery times.`,
        },
        {
          role: "user",
          content: csv,
        },
      ],
      //   max_tokens: 1000,
      temperature: 0.0,
      frequency_penalty: 0,
      presence_penalty: 0,
      stop: "null",
    };

    const bearerToken = await getToken();
    const response = await doQuery(bearerToken, body);
    const result = response.choices[0].message.content;
    console.log("Answer: \n" + result);

    return result;
  }
}

async function getToken() {
  const url =
    "https://btplearning-w4kbx4of.authentication.us10.hana.ondemand.com/oauth/token?grant_type=client_credentials&response_type=token";
  const username =
    "sb-324a213b-a68f-47da-a1cf-d4982eecc1eb!b120743|aicore!b164";
  const password =
    "63b785db-a833-4c0a-86ab-26ba2d752aa5$pQj6JcnQlYPyF-NI0ifjmEZXF84IvO5kceARCog4Q4k=";

  const headers = new Headers();
  headers.append("Authorization", "Basic " + btoa(username + ":" + password));

  return fetch(url, {
    method: "POST",
    headers: headers,
  })
    .then((response) => response.json())
    .then((data) => {
      return data.access_token;
    })
    .catch((error) => console.error(error));
}

async function doQuery(token, body) {
  const url =
    "https://api.ai.prod.us-east-1.aws.ml.hana.ondemand.com/v2/inference/deployments/d85ed0c1b02d8a27/chat/completions?api-version=2023-05-15";
  const headers = {
    "Content-Type": "application/json",
    "AI-Resource-Group": "default",
    Authorization: "Bearer " + token,
  };

  const requestOptions = {
    method: "POST",
    headers: headers,
    body: JSON.stringify(body),
  };

  return fetch(url, requestOptions)
    .then((response) => response.json())
    .then((data) => {
      return data;
    })
    .catch((error) => console.log(error));
}

module.exports = VRPAnalyticsService;
