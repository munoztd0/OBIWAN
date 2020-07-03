{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 1,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Import functions #\n",
    "import argparse,datetime,os,sys,time\n",
    "\n",
    "try:\n",
    "    import plotly.graph_objects as go\n",
    "except:\n",
    "    go = None  \n",
    "\n",
    "if go is None:\n",
    "    print(\"plotly is not installed\")\n",
    "\n",
    "import pandas as pd\n",
    "import numpy as np\n",
    "import plotly.graph_objects as go\n",
    "from ipywidgets import widgets\n",
    "\n",
    "from tools import load_groupfile, query_api, filterIQM, merge_dfs, make_vio_plot, make_vio_plot_df\n",
    "\n",
    "import ipywidgets as widgets\n",
    "from ipywidgets import interact, interact_manual"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 2,
   "metadata": {},
   "outputs": [],
   "source": [
    "#define widgets\n",
    "#modality_widget=widgets.Dropdown(\n",
    "#    options=['bold', 'structural'],\n",
    "#    description='Modality:',\n",
    "#    disabled=False)\n",
    "\n",
    "\n",
    "modality_widget=widgets.RadioButtons(\n",
    "    options=['bold', 'structural'],\n",
    "    description='Modality:',\n",
    "    disabled=False\n",
    ")\n",
    "\n",
    "TR_min=widgets.FloatSlider(\n",
    "    min=1.5,\n",
    "    max=5,\n",
    "    step=0.1,\n",
    "    description='TR min:',\n",
    "    disabled=False,\n",
    "    continuous_update=False,\n",
    "    orientation='horizontal',\n",
    "    readout=True,\n",
    "    readout_format='',\n",
    "    slider_color='white',\n",
    "    color='black'\n",
    ")\n",
    "\n",
    "\n",
    "TR_max=widgets.FloatSlider(\n",
    "    min=1.5,\n",
    "    max=4,\n",
    "    step=0.1,\n",
    "    description='TR max:',\n",
    "    disabled=False,\n",
    "    continuous_update=False,\n",
    "    orientation='horizontal',\n",
    "    readout=True,\n",
    "    readout_format='',\n",
    "    slider_color='white',\n",
    "    color='black'\n",
    ")\n",
    "\n",
    "\n",
    "\n",
    "TE_min=widgets.FloatSlider(\n",
    "    min=0,\n",
    "    max=.05,\n",
    "    step=0.001,\n",
    "    description='TE min:',\n",
    "    disabled=False,\n",
    "    continuous_update=False,\n",
    "    orientation='horizontal',\n",
    "    readout=True,\n",
    "    readout_format='',\n",
    "    slider_color='white',\n",
    "    color='black'\n",
    ")\n",
    "\n",
    "\n",
    "TE_max=widgets.FloatSlider(\n",
    "    min=0,\n",
    "    max=.05,\n",
    "    step=0.001,\n",
    "    description='TE max:',\n",
    "    disabled=False,\n",
    "    continuous_update=False,\n",
    "    orientation='horizontal',\n",
    "    readout=True,\n",
    "    readout_format='',\n",
    "    slider_color='white',\n",
    "    color='black'\n",
    ")\n",
    "\n",
    "\n",
    "select_parameters=widgets.SelectMultiple(\n",
    "    options=['TR_min', 'TR_max', 'TE_min', 'TE_max'],\n",
    "    description='Parameters',\n",
    "    disabled=False)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 3,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "application/vnd.jupyter.widget-view+json": {
       "model_id": "4e042b79e19e4ac792d0d5a498301b55",
       "version_major": 2,
       "version_minor": 0
      },
      "text/plain": [
       "RadioButtons(description='Modality:', options=('bold', 'structural'), value='bold')"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "display(modality_widget)"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 5,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "application/vnd.jupyter.widget-view+json": {
       "model_id": "435839b6f98448fa8fbfb3d8916e3e59",
       "version_major": 2,
       "version_minor": 0
      },
      "text/plain": [
       "SelectMultiple(description='Parameters', index=(0, 1), options=('TR_min', 'TR_max', 'TE_min', 'TE_max'), value…"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "text/plain": [
       "'If empty, no parameter restrictions will applied'"
      ]
     },
     "execution_count": 5,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "modal=modality_widget.value\n",
    "display(select_parameters)\n",
    "\"If empty, no parameter restrictions will applied\""
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 7,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "application/vnd.jupyter.widget-view+json": {
       "model_id": "fbddd4a751dc454ca2ea9ab36b437cba",
       "version_major": 2,
       "version_minor": 0
      },
      "text/plain": [
       "FloatSlider(value=2.4, continuous_update=False, description='TR min:', max=5.0, min=1.5, readout_format='')"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    },
    {
     "data": {
      "application/vnd.jupyter.widget-view+json": {
       "model_id": "923f211a39264691b5d8a56a2531cee2",
       "version_major": 2,
       "version_minor": 0
      },
      "text/plain": [
       "FloatSlider(value=2.7, continuous_update=False, description='TR max:', max=4.0, min=1.5, readout_format='')"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "for i in select_parameters.value:\n",
    "        display(eval(i))"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 51,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "['TR > 1.9', 'TR < 3']\n"
     ]
    }
   ],
   "source": [
    "to_filter=select_parameters.value\n",
    "filter_list=[]\n",
    "filter_dict={'TR_min': \"TR >= {}\".format(TR_min.value),\n",
    "             'TR_max': \"TR < {}\".format(TR_max.value),\n",
    "             'TE_min': \"TE >= {}\".format(TE_min.value),\n",
    "             'TE_max': \"TE < {}\".format(TE_max.value)\n",
    "            }\n",
    "\n",
    "for item in to_filter:\n",
    "    add_item=filter_dict.get(item)\n",
    "    filter_list.append(add_item)\n",
    "\n",
    "filter_list= ['TR > 1.9', 'TR < 3'] #whatcha\n",
    "print(filter_list)\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 52,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Arguments #\n",
    "\n",
    "# laziness helper\n",
    "# here = os.path.dirname(os.path.abspath(os.path.realpath(__file__)))\n",
    "here = %pwd\n",
    "homedir = os.path.expanduser('~/OBIWAN/')\n",
    "# path to input of local data from MRIQC on your own dataset \n",
    "#group_file = os.path.join(homedir,'DERIVATIVES', 'MRIQC', 'control_bold.tsv')\n",
    "#group_file = os.path.join(homedir,'DERIVATIVES', 'MRIQC', 'obese_bold.tsv')\n",
    "group_file = os.path.join(homedir,'DERIVATIVES', 'MRIQC', 'all_before_bold.tsv')\n",
    "#group_file = os.path.join(homedir,'DERIVATIVES', 'MRIQC','afterPREPROC',  'group_bold.tsv')\n",
    "#group_file = os.path.join(homedir,'DERIVATIVES', 'MRIQC', 'group_T1w.tsv')\n",
    "\n",
    "# scan type to query the API for [bold, T1w, T2w]\n",
    "modality = 'bold'\n",
    "#modality = 'T1w'\n",
    "\n",
    "# any scan parameters that you want to filter the API search results by\n",
    "\"\"\"Current possible filters:\n",
    "   Tesla, TE, TR\n",
    "   NOTE: Only working as *and* right now!\n",
    "\"\"\"\n",
    "\n",
    "\n",
    "# IQM variables to visualize\n",
    "#need to add separate IQMs for structural and functional\n",
    "IQM_to_plot = ['aor','aqi','dvars_nstd', 'tsnr', 'snr']\n",
    "               #tsnr', 'snr']\n",
    "               #'cjv','cnr', 'efc', 'snr_gm', 'snr_csf', 'rpve_gm', 'fwhm_avg']\n",
    "               #'aor','aqi','dvars_nstd', 'tsnr', 'snr']\n",
    "                    #'cjv','cnr', 'efc', 'snr_gm', 'snr_csf', 'rpve_gm', 'fwhm_avg'] # \n",
    "                    #'dvars_std','dvars_vstd',\n",
    "                    #'efc','fber','fd_mean','fd_num','fd_perc','fwhm_avg','fwhm_x','fwhm_y',\n",
    "                    #'fwhm_z','gcor','gsr_x','gsr_y','snr','summary_bg_k','summary_bg_mad',\n",
    "                    #'summary_bg_mean','summary_bg_median','summary_bg_n','summary_bg_p05',\n",
    "                    #'summary_bg_p95','summary_bg_stdv','summary_fg_k','summary_fg_mad',\n",
    "                    #'summary_fg_mean','summary_fg_median','summary_fg_n','summary_fg_p05',\n",
    "                    #'summary_fg_p95','summary_fg_stdv','dummy_trs']\n",
    "                    \n",
    "                      # variable names we might want to list\n",
    "    #qc_var_list = [\"aor\",\"aqi\",\"cjv\",\"cnr\",\"dummy_trs\",\"dvars_nstd\",\"dvars_std\",\"dvars_vstd\",\"efc\",\"fber\",\"fber\",\"fd_mean\",\"fd_num\",\"fd_perc\",\"fwhm_avg\",\"fwhm_avg\",\"fwhm_x\",\"fwhm_y\",\"fwhm_z\",\"gcor\",\"gsr_x\",\"gsr_y\",\"icvs_csf\",\"icvs_gm\",\n",
    "#\"icvs_wm\",\"inu_med\",\"inu_range\",\"qi_1\",\"qi_2\",\"rpve_csf\",\"rpve_gm\",\"rpve_wm\",\"snr\", \"snr_csf\",\"snr_gm\",\"snr_total\",\"snr_wm\",\"snrd_csf\",\"snrd_gm\",\"snrd_total\",\"snrd_wm\",\"summary_bg_k\",\"summary_bg_mad\",\"summary_bg_mean\",\"summary_bg_median\",\"summary_bg_n\",\n",
    "#\"summary_bg_p05\",\"summary_bg_p95\",\"summary_bg_stdv\",\"summary_csf_k\",\"summary_csf_mad\",\"summary_csf_mean\",\"summary_csf_median\",\"summary_csf_n\",\"summary_csf_p05\",\"summary_csf_p95\",\"summary_csf_stdv\",\"summary_fg_k\",\"summary_fg_mad\",\"summary_fg_mean\",\n",
    "#\"summary_fg_median\",\"summary_fg_n\",\"summary_fg_p05\",\"summary_fg_p95\",\"summary_fg_stdv\",\"summary_gm_k\",\"summary_gm_mad\",\"summary_gm_mean\",\"summary_gm_median\",\"summary_gm_n\",\"summary_gm_p05\",\"summary_gm_p95\",\"summary_gm_stdv\",\"summary_wm_k\",\"summary_wm_mad\",\n",
    "#\"summary_wm_mean\",\"summary_wm_median\",\"summary_wm_n\",\"summary_wm_p05\",\"summary_wm_p95\",\"summary_wm_stdv\",\"tpm_overlap_csf\",\"tpm_overlap_gm\",\"tpm_overlap_wm\",\"tsnr\",\"wm2max\"]"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 53,
   "metadata": {},
   "outputs": [
    {
     "data": {
      "text/plain": [
       "(598, 45)"
      ]
     },
     "execution_count": 53,
     "metadata": {},
     "output_type": "execute_result"
    }
   ],
   "source": [
    "# Load in your own data # \n",
    "\n",
    "# This should be a .csv or .tsv file outputted from MRIQC on your own data\n",
    "# This will return a pandas dataframe of the MRIQC data from your experiment\n",
    "\n",
    "userdf = load_groupfile(group_file)\n",
    "# userdf.head()\n",
    "userdf.shape\n",
    "\n",
    "\n"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 54,
   "metadata": {},
   "outputs": [],
   "source": [
    "#userdf = userdf.loc[0:10,:]\n",
    "#userdf.shape"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 55,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "(1000, 77)\n",
      "(834, 77)\n"
     ]
    }
   ],
   "source": [
    "# Load and filter data from the API # \n",
    "\n",
    "# Figure out which to get from modality arg #\n",
    "T1apicsv = os.path.join(here, 'demo_api', 'T1w_demo.csv')\n",
    "T2apicsv = os.path.join(here, 'demo_api', 'T2w_demo.csv')\n",
    "boldapicsv = os.path.join(here, 'demo_api', 'bold_demo.csv')\n",
    "\n",
    "if modality == 'T1w':\n",
    "    api_file = T1apicsv\n",
    "elif modality == 'T2w':\n",
    "    api_file = T1apicsv\n",
    "elif modality == 'bold':\n",
    "    api_file = boldapicsv\n",
    "\n",
    "# This will return a pandas dataframe with data from all scans of the given scan type\n",
    "# with the given parameters \n",
    "\n",
    "apidf = pd.read_csv(api_file)\n",
    "if not filter_list == []:\n",
    "    filtered_apidf = filterIQM(apidf,filter_list)\n",
    "else:\n",
    "    filtered_apidf = apidf\n",
    "\n",
    "# apidf.head()\n",
    "print(apidf.shape)\n",
    "# filtered_apidf.head()\n",
    "print(filtered_apidf.shape)\n",
    "#print(list(filtered_apidf))"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 56,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Loading in dataframe...\n",
      "Loading variables: ['aor', 'aqi', 'dvars_nstd', 'tsnr', 'snr']\n",
      "Loading in data descriptors...\n"
     ]
    },
    {
     "data": {
      "application/vnd.jupyter.widget-view+json": {
       "model_id": "e649b5b1ba79439eba919fbe80315665",
       "version_major": 2,
       "version_minor": 0
      },
      "text/plain": [
       "VBox(children=(Dropdown(description='IQM:', options=('aor', 'aqi', 'dvars_nstd', 'tsnr', 'snr'), value='aor'),…"
      ]
     },
     "metadata": {},
     "output_type": "display_data"
    }
   ],
   "source": [
    "# Merge dataframes # \n",
    "\n",
    "# Takes the user data and API data and merges it into one dataframe \n",
    "# This will return a single pandas dataframe with the local data and API data merged, with a \"group\" measure to allow for a \"groupby\" \n",
    "# this needs to be updated with actual function name and information about how to use  \n",
    "\n",
    "vis_ready_df = merge_dfs(userdf.copy(), filtered_apidf.copy())\n",
    "#print(vis_ready_df.head())\n",
    "#print(vis_ready_df.tail())\n",
    "vis_ready_df.shape\n",
    "\n",
    "\n",
    "\n",
    "v = make_vio_plot(vis_ready_df,IQM_to_plot,\"\", \"OBIWAN\",outliers=True)\n",
    "#after_preproc = v[2]\n",
    "widgets.VBox([v[0],v[1]])"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": []
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": []
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.7.6"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 2
}
