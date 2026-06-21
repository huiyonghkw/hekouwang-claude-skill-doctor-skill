# hekouwang-claude-skill-doctor-skill · 免费 CLI 体检器
# 零依赖：仅需 Python 标准库。
FROM python:3.12-slim

LABEL org.opencontainers.image.title="hekouwang-claude-skill-doctor-skill"
LABEL org.opencontainers.image.description="Agent Skill (SKILL.md) health checker — score + fixes"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/huiyonghkw/hekouwang-claude-skill-doctor-skill"

WORKDIR /app
COPY check.py /app/check.py

# 把要体检的 skill 目录挂到 /work 即可：
#   docker build -t claude-skill-doctor .
#   docker run --rm -v "$PWD:/work" claude-skill-doctor          # 体检挂载的 skill
#   docker run --rm -v "$PWD:/work" claude-skill-doctor /work --json
ENTRYPOINT ["python3", "/app/check.py"]
CMD ["/work"]
