FROM python:3.9-slim

RUN useradd -ms /bin/bash appuser

WORKDIR /app

COPY webserver.py .

RUN chown -R appuser /app

USER appuser

EXPOSE 8000

ENTRYPOINT ["python3", "webserver.py"]
