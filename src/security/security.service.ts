import { Injectable } from "@nestjs/common";
import { PrismaService } from 'src/prisma/prisma.service';
import { SetPinDTO } from "./dto/set-pin.dto";
import { RequestHeaders } from './../common/header-utils';
import axios from "axios";





@Injectable()
export class SecurityService {

    private readonly externalApiBase: string;

    constructor(private prisma: PrismaService) {
        this.externalApiBase = process.env.EXTERNAL_API_BASE_URL || '';
    }

    async setpin(payload: SetPinDTO, headers: RequestHeaders) {

        //External API Call to set PIN logic can be added here
        try {
            const response = await axios.post(`${this.externalApiBase}/pin/set`, payload,
                {
                    headers: {
                        'Authorization': `Bearer ${process.env.EXTERNAL_API_TOKEN}`,
                        'X-Request-ID': headers.requestId,  // Fixed: Use camelCase from RequestHeaders
                        'X-Correlation-ID': headers.correlationId,
                        'X-OrgId': headers.orgId,
                        'X-Timestamp': headers.timestamp.toISOString().split('T')[0],  // Format as YYYY-MM-DD
                        'X-SrcApp': headers.srcApp,
                        'X-Channel': headers.channel,
                        'Content-Type': 'application/json'
                    }
                })

            console.log('Response from external API:', response?.data);
            if(!response || response.status !== 200){
                throw new Error(`External API responded with status ${response?.status}`);
            }
            return response?.data;

        } catch (error) {
            throw new Error(`Failed to set PIN: ${error || 'Unknown error' }`);

        }


    }
}