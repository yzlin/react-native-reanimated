import React, { useState } from 'react';
import classnames from 'classnames';
import useBaseUrl from '@docusaurus/useBaseUrl';
import Layout from '@theme/Layout';
import styles from './styles.module.css';
import showcaseData from '@site/static/showcase.json';

function Filter({ expanded: expandedInitial }) {
  const [expanded, setExpanded] = useState(!!expandedInitial);
  const [filter, setFilter] = useState({});

  const resetAllFilters = () => {
    const notFiltered = Object.keys(filter).reduce((acc, key) => {
      acc[key] = false;
      return acc;
    }, {});
    setFilter(notFiltered);
  };

  const filterButton = (
    <>
      <button
        className={classnames(
          'button button--secondary button--lg',
          styles.filterButton
        )}
        onClick={() => setExpanded(!expanded)}>
        Filter ↑
      </button>
    </>
  );

  const filterExpanded = (
    <>
      <div className={styles.filter}>
        <article>
          <h2>Source code</h2>
          <button
            className={classnames(
              'button  button--lg',
              filter.available ? 'button--primary ' : 'button--outline'
            )}
            onClick={() =>
              setFilter({ ...filter, available: !filter.available })
            }>
            Available
          </button>
        </article>
        <button className="button button--primary button--lg margin-horiz--none">
          Show results
        </button>
        <button className={styles.resetFilters} onClick={resetAllFilters}>
          Reset filters
        </button>
      </div>
    </>
  );
  return (
    <>
      {filterButton}
      {expanded && filterExpanded}
    </>
  );
}

function Card({ title, name, imageUri, link, platform }) {
  return (
    <>
      <article className={styles.card}>
        {/* <img src="https://picsum.photos/217/470" /> */}

        <div className={styles.cardImgContainer}>
          <img src={imageUri} className={styles.cardImg} />
        </div>
        <div className={styles.cardDescription}>
          <h2 className={styles.cardTitle}>{title}</h2>
          <p className={classnames(styles.cardAuthor, 'margin--none')}>
            by{' '}
            <a href={link} className={styles.cardTextNick}>
              {name}
            </a>{' '}
            on {platform}
          </p>
        </div>
      </article>
    </>
  );
}

function Showcase() {
  return (
    <Layout>
      <div className={styles.containerWrapper}>
        <div className={styles.container}>
          <Filter expanded={false} />
          <div className={styles.cardsGrid}>
            {showcaseData.slice(0, 12 + 1).map((data, i) => (
              <Card key={i} {...data} />
            ))}
          </div>
        </div>
      </div>
    </Layout>
  );
}
export default Showcase;
