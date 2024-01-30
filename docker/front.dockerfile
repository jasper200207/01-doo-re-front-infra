FROM node:20-alpine AS base

# clone repository
FROM base As file
RUN apk add --no-cache git
WORKDIR /app

RUN git clone -b "Feature/#2-환경_설정" --single-branch https://github.com/BDD-CLUB/01-doo-re-front.git .

# install dependencies
FROM base AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app

COPY --from=file /app/package.json /app/package-lock.json ./
RUN npm ci

# next build
FROM base AS builder
WORKDIR /app
COPY --from=file /app /app
COPY --from=deps /app/node_modules ./node_modules

RUN npm run build

# run node server
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public

RUN mkdir .next
RUN chown nextjs:nodejs .next

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]