FROM base/devel

EXPOSE 3000

RUN pacman-db-upgrade
RUN pacman -Syyu --noconfirm
RUN pacman-key --refresh-keys 
RUN pacman -S git zsh --noconfirm
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
RUN pacman -S lua gvim --noconfirm
RUN pacman -S electron --noconfirm

#RUN pacman -S xorg-server xf86-video-intel --noconfirm
#RUN pacman -S xorg-xinit --noconfirm

RUN useradd -ms /bin/zsh dev
RUN passwd -d dev
RUN printf 'dev ALL=(ALL) ALL\n' | tee -a /etc/sudoers
RUN groupadd sudo
RUN usermod -a -G sudo dev

WORKDIR /home/dev
USER dev

WORKDIR /tmp
RUN git clone http://aur.archlinux.org/aurman.git
WORKDIR /tmp/aurman

ENV GPG_KEYS 465022E743D71E39
RUN ( gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEYS" \
  || gpg --keyserver pgp.mit.edu --recv-keys "$GPG_KEYS" \
  || gpg --keyserver keyserver.pgp.com --recv-keys "$GPG_KEYS" )
  
RUN sudo -u dev bash -c 'makepkg -Acs --noconfirm'
RUN sudo pacman -U aurman-2.16.9-1-any.pkg.tar.xz --noconfirm

RUN aurman -Syyu --noconfirm --noedit --skip_news
RUN aurman -S rbenv ruby-build --noconfirm --noedit --skip_news

RUN aurman -S oh-my-zsh-git keybase-bin silver-searcher-git --noconfirm --noedit --skip_news
RUN cp /usr/share/oh-my-zsh/zshrc ~/.zshrc
RUN rbenv install 2.5.1
RUN printf 'eval "$(rbenv init -)"' >> ~/.zshrc
# RUN run_keybase

RUN mkdir ~/Codez/
WORKDIR ~/Codez/
#RUN rbenv local 2.5.1

CMD ["zsh"]
