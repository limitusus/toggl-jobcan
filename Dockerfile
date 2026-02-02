FROM selenium/standalone-chrome:115.0

RUN sudo apt-get update
RUN sudo apt-get install -y git vim unzip gcc libssl-dev libreadline-dev  libz-dev patch build-essential make

ENV HOME /home/seluser
ENV ANYENV_ROOT $HOME/.anyenv
ENV RBENV_ROOT  $HOME/.anyenv/envs/rbenv
ENV PATH $ANYENV_ROOT/bin:$PATH
ENV PATH $RBENV_ROOT/bin:$PATH
ENV PATH $RBENV_ROOT/shims:$PATH

# anyenv
RUN git clone https://github.com/riywo/anyenv $HOME/.anyenv
RUN mkdir -p $HOME/.config/anyenv
RUN git clone https://github.com/anyenv/anyenv-install $HOME/.config/anyenv/anyenv-install

# rbenv
RUN anyenv install rbenv
RUN git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

# ruby
RUN rbenv install 3.1.4
RUN rbenv global 3.1.4

# toggl-jobcan
RUN gem install toggl-jobcan

ENTRYPOINT ["toggl-jobcan"]
CMD ["version"]
