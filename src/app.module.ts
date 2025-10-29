import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { ClientModule } from './client/client.module';
import { AccountModule } from './account/account.module';
import { CardModule } from './card/card.module';
import { CommonModule } from './common/common.module';
import { SecurityModule } from './security/security.module';



@Module({
  imports: [CommonModule, PrismaModule, ClientModule, AccountModule, CardModule, SecurityModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule { }
