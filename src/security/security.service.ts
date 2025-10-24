
import { Injectable } from "@nestjs/common";
import { PrismaClient } from "@prisma/client";
import { SetPinDTO } from "./dto/set-pin.dto";





@Injectable()
export class SecurityService{
    constructor(private prisma:PrismaClient){}

    async setpin(setPinDto:SetPinDTO){

        //

    }
}