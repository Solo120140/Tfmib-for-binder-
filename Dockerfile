# Use Ubuntu 18.04 as the base image
FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN lscpu
