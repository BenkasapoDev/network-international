<p align="center">
  <a href="http://nestjs.com/" target="blank"><img src="https://nestjs.com/img/logo-small.svg" width="120" alt="Nest Logo" /></a>
</p>

[circleci-image]: https://img.shields.io/circleci/build/github/nestjs/nest/master?token=abc123def456
[circleci-url]: https://circleci.com/gh/nestjs/nest

  <p align="center">A progressive <a href="http://nodejs.org" target="_blank">Node.js</a> framework for building efficient and scalable server-side applications.</p>
    <p align="center">
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/v/@nestjs/core.svg" alt="NPM Version" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/l/@nestjs/core.svg" alt="Package License" /></a>
<a href="https://www.npmjs.com/~nestjscore" target="_blank"><img src="https://img.shields.io/npm/dm/@nestjs/common.svg" alt="NPM Downloads" /></a>
<a href="https://circleci.com/gh/nestjs/nest" target="_blank"><img src="https://img.shields.io/circleci/build/github/nestjs/nest/master" alt="CircleCI" /></a>
<a href="https://discord.gg/G7Qnnhy" target="_blank"><img src="https://img.shields.io/badge/discord-online-brightgreen.svg" alt="Discord"/></a>
<a href="https://opencollective.com/nest#backer" target="_blank"><img src="https://opencollective.com/nest/backers/badge.svg" alt="Backers on Open Collective" /></a>
<a href="https://opencollective.com/nest#sponsor" target="_blank"><img src="https://opencollective.com/nest/sponsors/badge.svg" alt="Sponsors on Open Collective" /></a>
  <a href="https://paypal.me/kamilmysliwiec" target="_blank"><img src="https://img.shields.io/badge/Donate-PayPal-ff3f59.svg" alt="Donate us"/></a>
    <a href="https://opencollective.com/nest#sponsor"  target="_blank"><img src="https://img.shields.io/badge/Support%20us-Open%20Collective-41B883.svg" alt="Support us"></a>
  <a href="https://twitter.com/nestframework" target="_blank"><img src="https://img.shields.io/twitter/follow/nestframework.svg?style=social&label=Follow" alt="Follow us on Twitter"></a>
</p>
  <!--[![Backers on Open Collective](https://opencollective.com/nest/backers/badge.svg)](https://opencollective.com/nest#backer)
  [![Sponsors on Open Collective](https://opencollective.com/nest/sponsors/badge.svg)](https://opencollective.com/nest#sponsor)-->

## Description

[Nest](https://github.com/nestjs/nest) framework TypeScript starter repository.

## Project setup

```bash
$ npm install
```

## Compile and run the project

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Run tests

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Deployment

When you're ready to deploy your NestJS application to production, there are some key steps you can take to ensure it runs as efficiently as possible. Check out the [deployment documentation](https://docs.nestjs.com/deployment) for more information.

If you are looking for a cloud-based platform to deploy your NestJS application, check out [Mau](https://mau.nestjs.com), our official platform for deploying NestJS applications on AWS. Mau makes deployment straightforward and fast, requiring just a few simple steps:

```bash
$ npm install -g @nestjs/mau
$ mau deploy
```

With Mau, you can deploy your application in just a few clicks, allowing you to focus on building features rather than managing infrastructure.

## Resources

Check out a few resources that may come in handy when working with NestJS:

- Visit the [NestJS Documentation](https://docs.nestjs.com) to learn more about the framework.
- For questions and support, please visit our [Discord channel](https://discord.gg/G7Qnnhy).
- To dive deeper and get more hands-on experience, check out our official video [courses](https://courses.nestjs.com/).
- Deploy your application to AWS with the help of [NestJS Mau](https://mau.nestjs.com) in just a few clicks.
- Visualize your application graph and interact with the NestJS application in real-time using [NestJS Devtools](https://devtools.nestjs.com).
- Need help with your project (part-time to full-time)? Check out our official [enterprise support](https://enterprise.nestjs.com).
- To stay in the loop and get updates, follow us on [X](https://x.com/nestframework) and [LinkedIn](https://linkedin.com/company/nestjs).
- Looking for a job, or have a job to offer? Check out our official [Jobs board](https://jobs.nestjs.com).

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

## Stay in touch

- Author - [Kamil Myśliwiec](https://twitter.com/kammysliwiec)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

## License

Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).

## Prisma & MySQL

Quick steps to connect this project to a MySQL database using Prisma and run migrations.

1. Configure the database URL

  - Copy `.env.example` (or edit the existing `.env`) and set `DATABASE_URL` to point to your MySQL server.
  - Example format:

    ```properties
    DATABASE_URL="mysql://USER:PASSWORD@HOST:PORT/DATABASE"
    ```

  - Example local MySQL (update username/password/database as needed):

    ```properties
    DATABASE_URL="mysql://root:SecretPass@127.0.0.1:3306/network_international"
    ```

2. Install dependencies (if you haven't already)

  ```bash
  npm install
  ```

3. Generate Prisma Client

  ```bash
  npx prisma generate
  # or
  npm run prisma:generate
  ```

4. Create and apply a migration (development)

  This will create a migration in `prisma/migrations` and apply it to the database defined in `DATABASE_URL`.

  ```bash
  npx prisma migrate dev --name init
  # or
  npm run prisma:migrate -- --name init
  ```

  Notes:
  - If the command fails with a permissions/EPERM error on Windows related to the Prisma query engine, try stopping any running Node/Nest processes and re-run the command. Deleting the temporary `.tmp` file in `node_modules/.prisma/client` (if present) may be required.

5. Inspect the database with Prisma Studio

  ```bash
  npm run prisma:studio
  ```

6. Common troubleshooting

  - "Environment variables loaded from .env" — confirms Prisma read your `.env`.
  - EPERM / permission errors on Windows: stop running Node processes, delete any `*.tmp` files under `node_modules/.prisma/client/`, then re-run `npx prisma generate`.
  - If you change `schema.prisma`, re-run `npx prisma migrate dev` (or `npx prisma db pull` if you want to introspect an existing DB) and `npx prisma generate` afterward.

7. Production notes

  - For production deploys, use `prisma migrate deploy` to apply migrations non-interactively.
  - Store `DATABASE_URL` securely (secrets manager / environment variables). Avoid committing credentials.

## External API (ClientCreate)

This project forwards client-create requests to an external service. Configure the external API base URL with the `EXTERNAL_API_BASE_URL` environment variable (defaults to the sandbox URL):

```properties
EXTERNAL_API_BASE_URL="https://api-sandbox.network.global"
```

The local endpoint is:

- POST /client/create

Example to call the endpoint locally (PowerShell):

```powershell
# start the app first
npm run start:dev

# send the JSON payload saved in clientCreate.json
Invoke-RestMethod -Method Post -Uri 'http://localhost:3000/client/create' -ContentType 'application/json' -Body (Get-Content .\clientCreate.json -Raw)
```

The service will perform local DB upserts and then forward the original payload to `${EXTERNAL_API_BASE_URL}/V2/cardservices/ClientCreate`. The response JSON includes the local `customerId` and the external API status/data (or an `external.error` field if the forward failed).


