// src/common/common.module.ts
import { Module, Global } from '@nestjs/common';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { RequestHeadersInterceptor } from './request-headers.interceptor';

@Global()
@Module({
    providers: [
        {
            provide: APP_INTERCEPTOR,
            useClass: RequestHeadersInterceptor,
        },
    ],
})
export class CommonModule { }