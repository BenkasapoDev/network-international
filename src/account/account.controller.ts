import { Controller, Get, Post, Put, Delete, Body, Param, Query } from '@nestjs/common';
import { AccountService } from './account.service';
import type { CreateAccountPayload, UpdateAccountPayload } from './account.service';

@Controller('accounts')
export class AccountController {
    constructor(private readonly accountService: AccountService) { }

    @Post('create')
    async createAccount(@Body() payload: CreateAccountPayload) {
        try {
            const result = await this.accountService.createAccount(payload);
            return result;
        } catch (error) {
            return {
                success: false,
                message: error.message,
                error: error.name,
            };
        }
    }

    @Get(':id')
    async getAccount(@Param('id') accountId: string) {
        try {
            const result = await this.accountService.getAccount(accountId);
            return result;
        } catch (error) {
            return {
                success: false,
                message: error.message,
                error: error.name,
            };
        }
    }

    @Get()
    async getAccountsByClient(@Query('clientId') clientId: string) {
        try {
            const result = await this.accountService.getAccountsByClient(clientId);
            return result;
        } catch (error) {
            return {
                success: false,
                message: error.message,
                error: error.name,
            };
        }
    }

    @Put(':id')
    async updateAccount(
        @Param('id') accountId: string,
        @Body() payload: UpdateAccountPayload
    ) {
        try {
            const result = await this.accountService.updateAccount(accountId, payload);
            return result;
        } catch (error) {
            return {
                success: false,
                message: error.message,
                error: error.name,
            };
        }
    }

    @Delete(':id')
    async deleteAccount(@Param('id') accountId: string) {
        try {
            const result = await this.accountService.deleteAccount(accountId);
            return result;
        } catch (error) {
            return {
                success: false,
                message: error.message,
                error: error.name,
            };
        }
    }
}