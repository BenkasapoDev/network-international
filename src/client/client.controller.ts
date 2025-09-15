import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ClientService } from './client.service';
import type { CreateClientPayload } from './client.service';

@Controller('clients')
export class ClientController {
    constructor(private readonly clientService: ClientService) { }

    @Post('create')
    @HttpCode(HttpStatus.OK)
    async createClient(@Body() payload: CreateClientPayload) {
        return this.clientService.createClient(payload);
    }
}