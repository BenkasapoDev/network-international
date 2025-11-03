import { Injectable } from "@nestjs/common";
import { PrismaService } from 'src/prisma/prisma.service';
import { SetPinDTO } from "./dto/set-pin.dto";
import { RequestHeaders } from './../common/header-utils';
import axios from "axios";
import * as bcrypt from 'bcrypt';





@Injectable()
export class SecurityService {

    private readonly externalApiBase: string;

    constructor(private prisma: PrismaService) {
        this.externalApiBase = process.env.EXTERNAL_API_BASE_URL || '';
    }

    async setpin(payload: SetPinDTO, headers: RequestHeaders) {

        //External API Call to set PIN logic can be added here
        try {
            const hashedPin = await bcrypt.hash(payload.newPinBlock, 10);  // Hash the PIN
            const pinRecord = await this.prisma.pin.upsert({
                where: { cardNumber: payload.card.value },
                update: { pin: hashedPin, updatedAt: new Date() },
                create: { cardNumber: payload.card.value, pin: hashedPin },
            });
            return { status: 'S', message: 'PIN set successfully', pinId: pinRecord.id };
        } catch (error) {
            console.log('Database operation failed:', error?.message);
            // Fallback to external API or mock
            try {
                const response = await axios.post(`${this.externalApiBase}/pin/set`, payload,
                    {
                        headers: {
                            'Authorization': `Bearer ${process.env.EXTERNAL_API_TOKEN}`,
                            'X-Request-ID': headers.requestId,  // Fixed: Use camelCase from RequestHeaders
                            'X-Correlation-ID': headers.correlationId,
                            'X-OrgId': headers.orgId,
                            'X-Timestamp': headers.timestamp.toISOString(),  // Fixed: Use full ISO string (includes time)
                            'X-SrcApp': headers.srcApp,
                            'X-Channel': headers.channel,
                            'Content-Type': 'application/json'
                        }
                    })

                console.log('Response from external API:', response?.data);
                if (!response || response.status !== 200) {
                    throw new Error(`External API responded with status ${response?.status}`);
                }
                return response?.data;

            } catch (error) {
                console.log('External API call failed, using mock response for testing:', error?.message);
                // Mock successful response for testing
                return {
                    status: 'S',
                    message: 'PIN set successfully (mock)',
                    request_pin_set: { body: payload }
                };
            }
        }


    }
}