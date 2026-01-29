-- DropForeignKey
ALTER TABLE "GameLeaderboard" DROP CONSTRAINT "GameLeaderboard_gameSessionId_fkey";

-- AlterTable
ALTER TABLE "GameLeaderboard" ALTER COLUMN "gameSessionId" DROP NOT NULL;

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "password" TEXT;

-- AddForeignKey
ALTER TABLE "GameLeaderboard" ADD CONSTRAINT "GameLeaderboard_gameSessionId_fkey" FOREIGN KEY ("gameSessionId") REFERENCES "GameSession"("id") ON DELETE SET NULL ON UPDATE CASCADE;
