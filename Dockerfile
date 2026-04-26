# syntax=docker/dockerfile:1.10
FROM oven/bun@sha256:4b2a0f909e520adb526ef1c12fe0d1e8464fc7beba19140d688222647af68904 AS builder
# oven/bun:1.2.21-slim

WORKDIR /app

COPY package.json bun.lock tsconfig.json bunfig.toml ./
RUN bun install --frozen-lockfile

COPY src ./src
RUN mkdir -p dist && bun build --compile src/cli.ts --outfile dist/ts-bun

FROM gcr.io/distroless/base-debian12@sha256:af44c9fa601af3f07c6ccb72e7c5315cbba3581e74488e5f56988e3586652282
# gcr.io/distroless/base-debian12:nonroot

WORKDIR /app
COPY --from=builder /app/dist/ts-bun /usr/local/bin/ts-bun

USER 65532:65532
ENTRYPOINT ["/usr/local/bin/ts-bun"]
CMD ["--help"]
