FROM python:3.9-slim

WORKDIR /app

# Ensure old files are removed (this prevents caching issues)
RUN rm -rf /app/*

COPY app.py . 

RUN pip install flask

EXPOSE 8086

CMD ["python", "app.py"]
