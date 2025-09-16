import { Controller, Post, Body, HttpCode, HttpStatus, HttpException, HttpStatus as HttpStatusCode } from '@nestjs/common';
import { ClientService } from './client.service';
import type { CreateClientPayload } from './client.service';

@Controller('clients')
export class ClientController {
    constructor(private readonly clientService: ClientService) { }

    @Post('create')
    @HttpCode(HttpStatus.OK)
    async createClient(@Body() payload: CreateClientPayload) {
        try {
            return await this.clientService.createClient(payload);
        } catch (error) {
            console.error('ClientController.createClient error:', error);

            // Return detailed error information
            if (error.response) {
                // External API error
                throw new HttpException({
                    statusCode: error.response.status || 500,
                    message: `External API Error: ${error.message}`,
                    error: 'External API Failure',
                    details: {
                        externalStatus: error.response.status,
                        externalData: error.response.data,
                        url: error.config?.url
                    }
                }, error.response.status || HttpStatusCode.INTERNAL_SERVER_ERROR);
            } else if (error.code === 'ERR_INVALID_URL') {
                // URL configuration error
                throw new HttpException({
                    statusCode: HttpStatusCode.INTERNAL_SERVER_ERROR,
                    message: `Invalid URL Configuration: ${error.message}`,
                    error: 'Configuration Error',
                    details: {
                        input: error.input,
                        code: error.code
                    }
                }, HttpStatusCode.INTERNAL_SERVER_ERROR);
            } else {
                // Generic error
                throw new HttpException({
                    statusCode: HttpStatusCode.INTERNAL_SERVER_ERROR,
                    message: error.message || 'Internal server error',
                    error: 'Internal Server Error',
                    details: {
                        stack: error.stack,
                        name: error.name
                    }
                }, HttpStatusCode.INTERNAL_SERVER_ERROR);
            }
        }
    }
}