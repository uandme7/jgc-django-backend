#  Python 3.11이 설치된 Alpine Linux 3.19
# Alpine Linux는 경량화된 리눅스 배포판으로, 컨테이너 환경에 적합
# 빌드 자체가 반족이되는데, 이미지 자체가 무거우면 빌드 속도가 느려짐.
#ex) miniconda
FROM python:3.11-alpine3.19

# LABEL 명령어는 이미지에 메타데이터를 추가합니다. 여기서는 이미지의 유지 관리자를 "seopftware"로 지정하고 있습니다.
LABEL maintainer="uandme7"

# 환경 변수 PYTHONUNBUFFERED를 1로 설정합니다. 
# 컨테이너에 찍히는 로그를 볼수 있도록 허용
# 도커에 어떤 일이 일어나는지 알아야 디버깅 가능 / 실시간으로 보기
# 이는 Python이 표준 입출력 버퍼링을 비활성화하게 하여, 로그가 즉시 콘솔에 출력되게 합니다. 
# 이는 Docker 컨테이너에서 로그를 더 쉽게 볼 수 있게 합니다.
ENV PYTHONUNBUFFERED 1

# 로컬 파일 시스템의 requirements.txt 파일을 컨테이너의 /tmp/requirements.txt로 복사합니다. 
# 이 파일은 필요한 Python 패키지들을 명시합니다.
# tmp 에 넣는 이유 -> 컨테이너를 최대한 경량상태로 유지
# tmp 폴더는 빌드가 완료되면 삭제
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app

WORKDIR /app
EXPOSE 8000

ARG DEV=false

## && \ : Enter
RUN python -m venv /py && \ 
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user

# Django(Scikit—learn => REST API)
# ML f10닙 => ML OPS Docker Github Actions(CI/CD)