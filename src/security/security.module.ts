import { Module } from "@nestjs/common";
import { SecurityController } from "./security.controller";
import { SecurityService } from "./security.service";
import { PrismaModule } from "src/prisma/prisma.module";

@Module({
    controllers:[SecurityController],
    providers:[SecurityService],
    imports:[PrismaModule],
    exports:[SecurityService],
})
export class SecurityModule {}