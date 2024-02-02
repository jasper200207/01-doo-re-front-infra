FROM node:20-alpine AS base

WORKDIR /app

COPY data/front/build .

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

RUN chown nextjs:nodejs .

USER nextjs

ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]