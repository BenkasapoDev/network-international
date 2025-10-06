import { Module } from '@nestjs/common';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { ClientModule } from './client/client.module';
import { AccountModule } from './account/account.module';
import { CardModule } from './card/card.module';
import { RequestHeadersInterceptor } from './common/request-headers.interceptor';


@Module({
  imports: [PrismaModule, ClientModule, AccountModule, CardModule],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_INTERCEPTOR,
      useClass: RequestHeadersInterceptor,
    },
  ],
})
export class AppModule { }
