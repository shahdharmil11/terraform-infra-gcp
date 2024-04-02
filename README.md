# webapp

## Prerequisites

<img src="https://github.com/shahdharmil11/terraform-infra-gcp/blob/master/gcp-infra.png"  title="Infra provisioned">
Before we begin, we need to fulfill the following requirements:

- Java Development Kit (JDK) 17
- Maven --> pom.xml with relevant dependancies
- PostgreSQL Database --> credentials that are stored

## Build Instructions

To build the application, follow these steps:

Open terminal:
  1. Clone the repository on relevant path: git clone https://github.com/your-username/your-repository.git
  2. Open the project, check the github actions workflow and branch rules
  3. Make sure port 5432 is available for DB connection
  4. Make sure port 8080 is available for tomcat connection
  5. Complete MAven lifecycle to resolve dependency issues
  6. Start the application
  7. Open PostMan and create few instances first
  8. Then execute all of the required apis
