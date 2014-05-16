#!/usr/bin/env sh
# -*- coding: UTF-8 -*- 

###############################################################################
# Copyright (C) 2014 Armando Ibarra
#  v0.1 alpha - 2014
# 

#----------------------------------------------------------------------
# .sh
#
# Created: 07/04/2014
#
# Author: Ing. Armando Ibarra - armandoibarra1@gmail.com
#----------------------------------------------------------------------

# Push an existing repository on github


# Licensed under the GNU LGPL v2.1 - http://www.gnu.org/licenses/lgpl-2.1.html
# - or any later version.
# @author: Ing. Armando Ibarra

# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
###############################################################################

AUTHOR='Ing. Armando Ibarra <armandoibarra1@gmail.com>'
COPYRIGHT='Copyright (c) 2014, armandoibarra1@gmail.com'
LICENSE='GNU LGPL Version 2.1'

#variables
echo $AUTHOR
echo $COPYRIGHT
echo $LICENSE

URL_GIT_REPO="https://github.com/flaketill/erpmtics-desktop-manager-it.git"

setup_git()
{
	git config --global user.email "armandoibarra1@gmail.com"
	git config --global user.name "Armando Ibarra1"
	git remote add origin ${URL_GIT_REPO}

}

push_git()
{
	git push -u origin master
	git branch --set-upstream-to local-branch-name origin/remote-branch-name
}

install_git()
{
	sudo apt-get install git
}

main(){
	echo -e "install git"
	install_git
	echo -e "config git"
	setup_git
}

main


#
