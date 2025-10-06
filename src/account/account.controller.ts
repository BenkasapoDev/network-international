import { Controller, Get, Post, Put, Delete, Body, Param, Query, HttpException, InternalServerErrorException, HttpStatus, Req } from '@nestjs/common';
import { AccountService } from './account.service';
import type { CreateAccountPayload, UpdateAccountPayload } from './account.service';
import type { RequestHeaders } from '../common/header-utils';

@Controller('accounts')
export class AccountController {
    constructor(private readonly accountService: AccountService) { }

    @Post('create')
    async createAccount(@Body() payload: CreateAccountPayload, @Req() request: any) {
        try {
            const headers: RequestHeaders = request.validatedHeaders;
            const result = await this.accountService.createAccount(payload, headers);

            // Set appropriate status code based on whether account was created or already existed
            if (result.wasCreated) {
                // New account created - return 201 Created
                return {
                    success: result.success,
                    account: result.account,
                    message: result.message
                };
            } else {
                // Existing account found - return 200 OK
                const response = {
                    success: result.success,
                    account: result.account,
                    message: result.message
                };

                throw new HttpException(response, HttpStatus.OK);
            }
        } catch (error) {
            if (error instanceof HttpException) throw error;
            throw new InternalServerErrorException(error?.message || 'Internal server error');
        }
    }

    @Get(':id')
    async getAccount(@Param('id') accountId: string) {
        try {
            const result = await this.accountService.getAccount(accountId);
            return result;
        } catch (error) {
            if (error instanceof HttpException) throw error;
            throw new InternalServerErrorException(error?.message || 'Internal server error');
        }
    }

    @Get()
    async getAccountsByClient(@Query('clientId') clientId: string) {
        try {
            const result = await this.accountService.getAccountsByClient(clientId);
            return result;
        } catch (error) {
            if (error instanceof HttpException) throw error;
            throw new InternalServerErrorException(error?.message || 'Internal server error');
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
            if (error instanceof HttpException) throw error;
            throw new InternalServerErrorException(error?.message || 'Internal server error');
        }
    }

    @Delete(':id')
    async deleteAccount(@Param('id') accountId: string) {
        try {
            const result = await this.accountService.deleteAccount(accountId);
            return result;
        } catch (error) {
            if (error instanceof HttpException) throw error;
            throw new InternalServerErrorException(error?.message || 'Internal server error');
        }
    }
}