import { Controller, Post, Get, Delete, Body, Param, HttpException, InternalServerErrorException, BadRequestException, HttpStatus, HttpCode, Req } from '@nestjs/common';
import { CardService } from './card.service';
import type { CreateCardPayload } from './card.service';
import type { RequestHeaders } from '../common/header-utils';

@Controller('cards')
export class CardController {
    constructor(private readonly cardService: CardService) { }

    @Post('create')
    async createCard(@Body() payload: CreateCardPayload, @Req() request: any) {
        try {
            console.log('CardController.createCard received payload:', JSON.stringify(payload));
            if (!payload || (typeof payload === 'object' && Object.keys(payload).length === 0)) {
                throw new BadRequestException('Empty request body. Ensure Content-Type: application/json and a JSON body is sent.');
            }

            const headers: RequestHeaders = request.validatedHeaders;
            const result = await this.cardService.createCard(payload, headers);

            // Set appropriate status code based on whether card was created or updated
            if (result.wasCreated) {
                // New card created - return 201 Created
                return {
                    success: result.success,
                    card: result.card,
                    message: result.message
                };
            } else {
                // Existing card found - return 200 OK with custom status
                const response = {
                    success: result.success,
                    card: result.card,
                    message: result.message
                };

                // Manually set status to 200 for existing cards
                throw new HttpException(response, HttpStatus.OK);
            }
        } catch (error) {
            if (error instanceof HttpException) throw error;
            throw new InternalServerErrorException(error?.message || 'Internal server error');
        }
    }


    @Get(':id')
    async getCard(@Param('id') id: string) {
        try {
            const result = await this.cardService.getCard(id);
            return result;
        } catch (error) {
            if (error instanceof HttpException) throw error;
            throw new InternalServerErrorException(error?.message || 'Internal server error');
        }
    }

    @Delete(':id')
    async deleteCard(@Param('id') id: string) {
        try {
            const result = await this.cardService.deleteCard(id);
            return result;
        } catch (error) {
            if (error instanceof HttpException) throw error;
            throw new InternalServerErrorException(error?.message || 'Internal server error');
        }
    }
}